import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/quiz_repository.dart';
import 'package:trivia/ui/screens/result_screen.dart';
import 'package:trivia/ui/widgets/game_choice_button.dart';
import 'package:trivia/ui/widgets/game_header.dart';
import 'package:trivia/utils/scoring.dart';

/// How long the revealed answer stays on screen before the next question.
const Duration _revealDelay = Duration(milliseconds: 900);

/// Seconds left at which the countdown switches to the error colour.
const int _urgentThreshold = 5;

/// The quiz round.
///
/// The whole round is driven by one small state machine:
///
/// * `_prepareQuestion()` resets the per-question state,
/// * `_revealAnswer()` locks the answer in (or reveals it on timeout),
/// * `_finishQuestion()` scores it and advances, or ends the round.
///
/// Previously the countdown and the answer handlers each advanced
/// `_currentQuestion` on their own. The timeout branch restarted the timer
/// unconditionally - even after the final question - so a finished round kept
/// ticking in the background and could increment past the end of the list.
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key, required this.item});

  /// Either a [Level] or a [Category].
  final Object? item;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  final Random _random = Random();
  late final AudioPlayer _audioPlayer;

  Level? _level;
  Category? _category;

  List<Trivia> _questions = const <Trivia>[];
  List<ChoiceStatus> _statuses = const <ChoiceStatus>[];

  int _currentQuestion = 0;
  int _score = 0;
  int _roundSize = questionsPerLevel;
  int _secondsLeft = 0;
  int _secondsPerQuestion = defaultSecondsPerQuestion;

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _loading = true;
  bool _answered = false;
  bool _navigatedToResult = false;
  bool _dialogOpen = false;

  String? _error;
  Timer? _timer;

  Trivia get _trivia => _questions[_currentQuestion];

  bool get _timerEnabled => _secondsPerQuestion > 0;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item is Level) {
      _level = item;
    } else if (item is Category) {
      _category = item;
    }

    final settings = context.read<SettingsProvider>().settings;
    _soundEnabled = settings.soundEnabled;
    _hapticsEnabled = settings.hapticsEnabled;
    _secondsPerQuestion = settings.secondsPerQuestion;
    // Campaign levels are fixed length; free-play categories honour the
    // "questions per round" preference.
    _roundSize = _category != null
        ? settings.categoryRoundSize
        : questionsPerLevel;

    _audioPlayer = AudioPlayer();

    if (_level == null && _category == null) {
      _loading = false;
      _error = 'No quiz was selected.';
    } else {
      unawaited(_loadQuestions());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final questions = await QuizRepository.questionsFor(
        widget.item as Object,
        count: _roundSize,
        random: _random,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _currentQuestion = 0;
        _score = 0;
        _loading = false;
        if (questions.isNotEmpty) _prepareQuestion();
      });
      if (_questions.isNotEmpty) _startTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load questions. Please try again.';
      });
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (_) {
      // Audio is a nice-to-have; never let it break the round.
    }
  }

  // ---------------------------------------------------------------------------
  // Round flow
  // ---------------------------------------------------------------------------

  void _prepareQuestion() {
    _answered = false;
    _secondsLeft = _secondsPerQuestion;
    _statuses = List<ChoiceStatus>.filled(
      _trivia.choices.length,
      ChoiceStatus.idle,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_timerEnabled) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _revealAnswer(selected: null);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _onChoiceTap(int index) {
    if (_answered || _loading) return;
    if (_hapticsEnabled) unawaited(HapticFeedback.selectionClick());
    _revealAnswer(selected: index);
  }

  /// Locks the current question: paints the correct answer, paints the wrong
  /// pick (if any), stops the countdown and hands over to [_finishQuestion].
  void _revealAnswer({required int? selected}) {
    if (_answered) return;
    _answered = true;
    _timer?.cancel();

    final choices = _trivia.choices;
    final correctIndex = choices.indexOf(_trivia.answer);
    final isCorrect = selected != null && selected == correctIndex;

    setState(() {
      _statuses = List<ChoiceStatus>.generate(choices.length, (index) {
        if (index == correctIndex) return ChoiceStatus.correct;
        if (index == selected) return ChoiceStatus.wrong;
        return ChoiceStatus.muted;
      });
      if (isCorrect) _score++;
    });

    if (_soundEnabled) {
      unawaited(
        _playSound(
          isCorrect ? 'assets/audio/correct.mp3' : 'assets/audio/wrong.mp3',
        ),
      );
    }

    unawaited(_finishQuestion());
  }

  Future<void> _finishQuestion() async {
    await Future<void>.delayed(_revealDelay);
    if (!mounted || _navigatedToResult) return;

    if (_currentQuestion >= _questions.length - 1) {
      _goToResults();
      return;
    }

    setState(() {
      _currentQuestion++;
      _prepareQuestion();
    });
    _startTimer();
  }

  void _goToResults() {
    if (_navigatedToResult) return;
    _navigatedToResult = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          score: _score,
          total: _questions.length,
          resultSoundAsset: resultSoundAsset(_score, _questions.length),
          levelId: _level?.id,
          categoryId: _category?.categoryId,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chrome
  // ---------------------------------------------------------------------------

  Future<void> _showExitDialog() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    // Pause the countdown while the player decides.
    _timer?.cancel();
    try {
      final stay = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogTheme = Theme.of(dialogContext);
          return AlertDialog(
            title: const Text('Exit game?'),
            content: const Text(
              'Do you want to stop the game? Your current progress will be lost.',
            ),
            actions: [
              FilledButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                    dialogTheme.colorScheme.onErrorContainer,
                  ),
                  backgroundColor: WidgetStatePropertyAll(
                    dialogTheme.colorScheme.errorContainer,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Exit'),
              ),
              FilledButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Continue game'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      if (stay != true) {
        Navigator.of(context).pop();
        return;
      }
      // Resume only when the round is still live.
      if (!_answered && !_navigatedToResult && !_loading) _startTimer();
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _showExitDialog();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildBody(Theme.of(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_error != null) {
      return _CenteredMessage(
        icon: Icons.error_outline,
        title: _error!,
        actionLabel: 'Try again',
        onAction: _loadQuestions,
      );
    }
    if (_questions.isEmpty) {
      return _CenteredMessage(
        icon: Icons.inbox_outlined,
        title: 'No questions available for this quiz yet.',
        actionLabel: 'Back to home',
        onAction: () => Navigator.of(context).pop(),
      );
    }
    return _buildQuestion(theme);
  }

  Widget _buildQuestion(ThemeData theme) {
    return Column(
      children: [
        GameHeader(
          current: _currentQuestion + 1,
          total: _questions.length,
          score: _score,
          category: _category,
          level: _level,
          onExit: _showExitDialog,
        ),
        const SizedBox(height: 8),
        _CountdownBar(
          secondsLeft: _secondsLeft,
          secondsTotal: _secondsPerQuestion,
          enabled: _timerEnabled,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  _trivia.question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                for (final (index, choice) in _trivia.choices.indexed) ...[
                  if (index > 0) const SizedBox(height: 16),
                  GameChoiceButton(
                    label: choice,
                    status: _statuses.length > index
                        ? _statuses[index]
                        : ChoiceStatus.idle,
                    onPressed: _answered ? null : () => _onChoiceTap(index),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Countdown for the current question, including a "no time limit" state.
class _CountdownBar extends StatelessWidget {
  const _CountdownBar({
    required this.secondsLeft,
    required this.secondsTotal,
    required this.enabled,
  });

  final int secondsLeft;
  final int secondsTotal;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!enabled) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.all_inclusive,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            'No time limit',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final isUrgent = secondsLeft <= _urgentThreshold;
    final color = isUrgent
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final progress = secondsTotal <= 0
        ? 0.0
        : (secondsLeft / secondsTotal).clamp(0.0, 1.0);

    return Semantics(
      label: 'Time remaining',
      value: '$secondsLeft seconds',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                '${secondsLeft}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple empty/error state with a single action button.
class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

