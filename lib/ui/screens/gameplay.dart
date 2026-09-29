import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/answered_question.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/models/round_outcome.dart';
import 'package:trivia/models/round_result.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/repository/quiz_repository.dart';
import 'package:trivia/repository/stats_repository.dart';
import 'package:trivia/ui/screens/result_screen.dart';
import 'package:trivia/ui/widgets/game_choice_button.dart';
import 'package:trivia/ui/widgets/game_controls_bar.dart';
import 'package:trivia/ui/widgets/game_header.dart';
import 'package:trivia/utils/scoring.dart';
import 'package:trivia/utils/sound_player.dart';
import 'package:trivia/l10n/l10n.dart';

/// How long the revealed answer stays on screen before the next question.
const Duration _revealDelay = Duration(milliseconds: 900);

/// Seconds left at which the countdown switches to the error colour.
const int _urgentThreshold = 5;

/// The quiz round.
///
/// One small state machine drives everything:
///
/// * `_prepareQuestion()` resets the per-question state (including reshuffling
///   the choices so the correct answer is not always in the authored slot),
/// * `_revealAnswer()` locks the answer in - whether the player tapped, used the
///   skip lifeline, or the countdown ran out,
/// * `_finishQuestion()` scores it and either advances or ends the round.
///
/// Lifelines (50:50, skip, +10s) and pause are layered on top through
/// `_eliminated`, `_skipUsed`, `_extraTimeUsed` and `_paused`.
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key, required this.request});

  final QuizRequest request;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen>
    with WidgetsBindingObserver {
  final Random _random = Random();
  final SoundPlayer _sounds = SoundPlayer();

  List<Trivia> _questions = const <Trivia>[];
  List<ChoiceStatus> _statuses = const <ChoiceStatus>[];
  List<String> _choices = const <String>[];
  final List<AnsweredQuestion> _answers = <AnsweredQuestion>[];

  /// Choices removed by the 50:50 lifeline for the current question.
  Set<int> _eliminated = <int>{};

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
  bool _paused = false;
  bool _fiftyFiftyUsed = false;
  bool _skipUsed = false;
  bool _extraTimeUsed = false;

  String? _error;
  Timer? _timer;

  Trivia get _trivia => _questions[_currentQuestion];

  bool get _timerEnabled => _secondsPerQuestion > 0;

  /// Lifelines are only offered while the question is still open.
  bool get _controlsEnabled => !_answered && !_loading && !_paused;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final settings = context.read<SettingsProvider>().settings;
    _soundEnabled = settings.soundEnabled;
    _hapticsEnabled = settings.hapticsEnabled;
    _secondsPerQuestion = settings.secondsPerQuestion;
    _roundSize = widget.request.roundSizeFor(
      categoryRoundSize: settings.categoryRoundSize,
    );
    _sounds.enabled = _soundEnabled;

    unawaited(_sounds.load());
    unawaited(_loadQuestions());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_sounds.dispose());
    super.dispose();
  }

  /// Pause the round when the app leaves the foreground.
  ///
  /// Dart timers keep firing while the app is backgrounded, so without this the
  /// round could advance (or even finish) while the player was not looking.
  /// Returning to a paused round also stops the question being read for free.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) return;
    if (_loading || _answered || _navigatedToResult || _paused) return;
    setState(() => _paused = true);
    _timer?.cancel();
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
        widget.request,
        roundSize: _roundSize,
        random: _random,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _currentQuestion = 0;
        _score = 0;
        _answers.clear();
        _loading = false;
        if (questions.isNotEmpty) _prepareQuestion();
      });
      if (_questions.isNotEmpty) _startTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load questions.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Round flow
  // ---------------------------------------------------------------------------

  void _prepareQuestion() {
    _answered = false;
    _secondsLeft = _secondsPerQuestion;
    _eliminated = <int>{};
    // Reshuffle so the correct answer is not always in the authored position.
    _choices = List<String>.of(_trivia.choices)..shuffle(_random);
    _statuses = List<ChoiceStatus>.filled(_choices.length, ChoiceStatus.idle);
  }

  void _startTimer() {
    _timer?.cancel();
    // Nothing to count down for when the round is empty or already resolved.
    if (!_timerEnabled || _questions.isEmpty || _answered || _paused) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _revealAnswer(timedOut: true);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _onChoiceTap(int index) {
    if (!_controlsEnabled || _eliminated.contains(index)) return;
    if (_hapticsEnabled) unawaited(HapticFeedback.selectionClick());
    _revealAnswer(selected: index);
  }

  /// Locks the current question and hands over to [_finishQuestion].
  ///
  /// [selected] is the tapped choice, `null` for a timeout or a skip.
  void _revealAnswer({
    int? selected,
    bool timedOut = false,
    bool skipped = false,
  }) {
    if (_answered) return;
    _answered = true;
    _timer?.cancel();

    final correctIndex = _choices.indexOf(_trivia.answer);
    final isCorrect = selected != null && selected == correctIndex;
    final answered = AnsweredQuestion(
      trivia: _trivia,
      presentedChoices: List<String>.of(_choices),
      selectedChoice: selected == null ? null : _choices[selected],
      timedOut: timedOut,
    );

    setState(() {
      _statuses = List<ChoiceStatus>.generate(_choices.length, (index) {
        if (index == correctIndex) return ChoiceStatus.correct;
        if (index == selected) return ChoiceStatus.wrong;
        if (_eliminated.contains(index)) return ChoiceStatus.eliminated;
        return ChoiceStatus.muted;
      });
      if (isCorrect) _score++;
      _answers.add(answered);
    });

    if (skipped) {
      // A skipped question is neither shown nor mistaken as far as the
      // statistics are concerned; it simply does not score.
      unawaited(_finishQuestion(skipped: true));
      return;
    }

    unawaited(
      StatsRepository.recordAnswer(
        question: _trivia.question,
        correct: isCorrect,
        category: _trivia.category,
      ),
    );
    if (_soundEnabled) {
      unawaited(
        _sounds.play(isCorrect ? SoundPlayer.correct : SoundPlayer.wrong),
      );
    }
    unawaited(_finishQuestion());
  }

  Future<void> _finishQuestion({bool skipped = false}) async {
    await Future<void>.delayed(
      skipped ? const Duration(milliseconds: 250) : _revealDelay,
    );
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
        builder:
            (_) => ResultScreen(
              outcome: RoundOutcome(
                request: widget.request,
                score: _score,
                answers: List<AnsweredQuestion>.of(_answers),
              ),
            ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lifelines and pause
  // ---------------------------------------------------------------------------

  /// Removes two wrong answers from play.
  void _useFiftyFifty() {
    if (!_controlsEnabled || _fiftyFiftyUsed) return;
    final correctIndex = _choices.indexOf(_trivia.answer);
    final wrongIndices = <int>[
      for (var index = 0; index < _choices.length; index++)
        if (index != correctIndex) index,
    ]..shuffle(_random);

    setState(() {
      _fiftyFiftyUsed = true;
      _eliminated = wrongIndices.take(2).toSet();
      for (final index in _eliminated) {
        _statuses[index] = ChoiceStatus.eliminated;
      }
    });
    if (_soundEnabled) unawaited(_sounds.play(SoundPlayer.click));
  }

  /// Moves on without scoring the current question.
  void _useSkip() {
    if (!_controlsEnabled || _skipUsed) return;
    setState(() => _skipUsed = true);
    _revealAnswer(skipped: true);
  }

  /// Adds [extraTimeSeconds] to the countdown.
  void _useExtraTime() {
    if (!_controlsEnabled || _extraTimeUsed || !_timerEnabled) return;
    setState(() {
      _extraTimeUsed = true;
      _secondsLeft += extraTimeSeconds;
    });
    _startTimer();
    if (_soundEnabled) unawaited(_sounds.play(SoundPlayer.click));
  }

  void _togglePause() {
    if (_navigatedToResult || _loading) return;
    setState(() => _paused = !_paused);
    if (_paused) {
      _timer?.cancel();
    } else if (!_answered) {
      _startTimer();
    }
  }

  // ---------------------------------------------------------------------------
  // Chrome
  // ---------------------------------------------------------------------------

  void _handleBack() {
    if (_paused) {
      _togglePause();
      return;
    }
    unawaited(_showExitDialog());
  }

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
            title: Text(context.l10n.exitGameTitle),
            content: Text(context.l10n.exitGameBody),
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
                child: Text(context.l10n.exit),
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
                child: Text(context.l10n.continueGame),
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
      // Resume only when the round is still live and not paused.
      if (!_answered && !_navigatedToResult && !_loading) _startTimer();
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _handleBack();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              children: [
                _buildBody(theme),
                if (_paused && !_loading && _questions.isNotEmpty)
                  PausedOverlay(
                    onResume: _togglePause,
                    onExit: _showExitDialog,
                  ),
              ],
            ),
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
        actionLabel: context.l10n.tryAgain,
        onAction: _loadQuestions,
      );
    }
    if (_questions.isEmpty) {
      return _CenteredMessage(
        icon: Icons.inbox_outlined,
        title: switch (widget.request.mode) {
          RoundMode.practice => context.l10n.nothingToPractise,
          _ => context.l10n.noQuestions,
        },
        actionLabel: context.l10n.backToHome,
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
          category: widget.request.category,
          level: widget.request.level,
          modeLabel: switch (widget.request.mode) {
            RoundMode.daily => context.l10n.modeDaily,
            RoundMode.practice => context.l10n.modePractice,
            _ => null,
          },
          onExit: () => unawaited(_showExitDialog()),
        ),
        const SizedBox(height: 8),
        _CountdownBar(
          secondsLeft: _secondsLeft,
          secondsTotal: _secondsPerQuestion,
          enabled: _timerEnabled,
        ),
        const SizedBox(height: 8),
        GameControlsBar(
          enabled: _controlsEnabled,
          paused: _paused,
          timerEnabled: _timerEnabled,
          fiftyFiftyUsed: _fiftyFiftyUsed,
          skipUsed: _skipUsed,
          extraTimeUsed: _extraTimeUsed,
          onFiftyFifty: _useFiftyFifty,
          onSkip: _useSkip,
          onExtraTime: _useExtraTime,
          onTogglePause: _togglePause,
        ),
        const SizedBox(height: 12),
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
                for (final (index, choice) in _choices.indexed) ...[
                  if (index > 0) const SizedBox(height: 16),
                  GameChoiceButton(
                    label: choice,
                    status:
                        _statuses.length > index
                            ? _statuses[index]
                            : ChoiceStatus.idle,
                    onPressed:
                        _controlsEnabled && !_eliminated.contains(index)
                            ? () => _onChoiceTap(index)
                            : null,
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
            context.l10n.noTimeLimit,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final isUrgent = secondsLeft <= _urgentThreshold;
    final color =
        isUrgent ? theme.colorScheme.error : theme.colorScheme.primary;
    final progress =
        secondsTotal <= 0 ? 0.0 : (secondsLeft / secondsTotal).clamp(0.0, 1.0);

    return Semantics(
      label: context.l10n.timeRemaining,
      value: context.l10n.secondsValue(secondsLeft),
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
