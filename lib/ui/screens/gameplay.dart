import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/trivia.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/ui/widgets/game_choice_button.dart';
import 'package:trivia/ui/widgets/game_header.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/settings.dart';
import 'package:flutter/scheduler.dart';
import 'result_screen.dart';

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key, required this.item});

  final dynamic item;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  Level? _level;
  Category? _category;
  int _currentQuestion = 0;
  int _score = 0;
  Timer? _timer;
  int _start = 30;
  bool _buttonsEnabled = true;
  // persistent button colors for current question so updates reflect in UI
  List<Color> _buttonColors = [];
  int _buttonColorsForQuestion = -1;
  late final AudioPlayer _audioPlayer;
  bool _navigatedToResult = false;
  // cache questions so FutureBuilder doesn't refetch on every rebuild
  Future<List<Trivia>>? _questionsFuture;

  @override
  void initState() {
    super.initState();
    final item = _getItem();
    if (item is Level) {
      _level = item;
    } else {
      _category = item as Category;
    }
    _audioPlayer = AudioPlayer();
    _questionsFuture = _getQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (_) {
      // ignore
    }
  }

  void _startTimer({bool reset = false}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start <= 0 || reset) {
        // when timer reaches zero move to next question after a short delay
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _start = 30;
              _currentQuestion++;
            });
            // restart timer only if there are more questions; caller must ensure bounds
            _startTimer();
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  dynamic _getItem() => widget.item;

  Future<List<Trivia>> _getQuestions() async {
    final isar = Repository.isar;
    if (_level != null) {
      return await isar.trivias
          .filter()
          .levelEqualTo(_level!.id)
          .limit(10)
          .findAll();
    } else {
      final allIds =
          await isar.trivias
              .where()
              .categoryEqualTo(_category!.categoryId)
              .idProperty()
              .findAll();
      if (allIds.isEmpty) return [];
      final random = Random();
      final selectedIds = <int>{};

      // pick up to 20 random ids
      while (selectedIds.length < 20 && selectedIds.length < allIds.length) {
        selectedIds.add(allIds[random.nextInt(allIds.length)]);
      }
      final finalList = await isar.trivias.getAll(selectedIds.toList());
      return finalList.whereType<Trivia>().toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void showExitDialog() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Exit game?'),
              content: const Text(
                'Do you want to stop the game? Your current progress will be lost.',
              ),
              actions: [
                FilledButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(
                      theme.colorScheme.onErrorContainer,
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      theme.colorScheme.errorContainer,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Exit'),
                ),
                FilledButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(
                      theme.colorScheme.onSurface,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continue game'),
                ),
              ],
            ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) showExitDialog();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: FutureBuilder<List<Trivia>>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(child: Text('No questions available'));
                }

                // ensure current index is within bounds
                if (_currentQuestion >= data.length) {
                  // navigate to result screen once and play result sound
                  if (!_navigatedToResult) {
                    _navigatedToResult = true;
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      final numberOfStars =
                          ((_score / data.length) * 3).round();
                      final sound =
                          numberOfStars >= 2
                              ? 'assets/audio/applause.mp3'
                              : 'assets/audio/aww.mp3';
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (context) => ResultScreen(
                                score: _score,
                                total: data.length,
                                resultSoundAsset: sound,
                                levelId: _level?.id,
                                categoryId: _category?.categoryId,
                              ),
                        ),
                      );
                    });
                  }
                  // while waiting for navigation, show a placeholder
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final currentTrivia = data[_currentQuestion];
                final question = currentTrivia.question;
                final choices =
                    currentTrivia.choices;
                final answer = currentTrivia.answer;
                // ensure _buttonColors is initialized for this question
                if (_buttonColorsForQuestion != _currentQuestion ||
                    _buttonColors.length != choices.length) {
                  _buttonColors = List.filled(
                    choices.length,
                    theme.colorScheme.onSurface,
                  );
                  _buttonColorsForQuestion = _currentQuestion;
                }
                return Column(
                  children: [
                    GameHeader(
                      current: _currentQuestion + 1,
                      total: data.length,
                      score: _score,
                      category: _category,
                      level: _level,
                      onExit: showExitDialog,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _start.toString(),
                      style: theme.textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 2.0,
                          bottom: 8,
                          left: 8,
                          right: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              question,
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Column(
                              children: List.generate(choices.length, (
                                int index,
                              ) {
                                final choice = choices[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index == choices.length - 1 ? 0 : 16,
                                  ),
                                  child: GameChoiceButton(
                                    label: choice,
                                    backgroundColor:
                                        _buttonColors[index] ==
                                                theme.colorScheme.onSurface
                                            ? Colors.transparent
                                            : _buttonColors[index],
                                    foregroundColor:
                                        _buttonColors[index] ==
                                                theme.colorScheme.onSurface
                                            ? theme.colorScheme.onSurface
                                            : (_buttonColors[index] ==
                                                    theme
                                                        .colorScheme
                                                        .primaryContainer
                                                ? theme
                                                    .colorScheme
                                                    .onPrimaryContainer
                                                : theme
                                                    .colorScheme
                                                    .onErrorContainer),
                                    outlineColor: theme.colorScheme.outline,
                                    onPressed:
                                        _buttonsEnabled
                                            ? () {
                                              // disable buttons until next question
                                              setState(() {
                                                _buttonsEnabled = false;
                                              });

                                              void nextTask({
                                                required bool correct,
                                              }) {
                                                _timer?.cancel();
                                                if (correct) _score++;
                                                Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () {
                                                    if (!mounted) return;
                                                    setState(() {
                                                      _start = 30;
                                                      _currentQuestion++;
                                                      // re-enable buttons for the next question
                                                      _buttonsEnabled = true;
                                                    });
                                                    if (_currentQuestion <
                                                        data.length) {
                                                      _startTimer();
                                                    }
                                                  },
                                                );
                                              }

                                              final correctIndex = choices
                                                  .indexOf(answer);

                                              final correctColor = Colors.green;

                                              final shouldPlaySound =
                                                  Provider.of<SettingsProvider>(
                                                    context,
                                                    listen: false,
                                                  ).settings.soundEnabled;

                                              if (choice == answer) {
                                                setState(() {
                                                  // use theme-based green for correct answer
                                                  _buttonColors[index] =
                                                      correctColor;
                                                });
                                                if (shouldPlaySound) {
                                                  _playSound(
                                                    'assets/audio/correct.mp3',
                                                  );
                                                }
                                                nextTask(correct: true);
                                              } else {
                                                setState(() {
                                                  _buttonColors[index] =
                                                      theme
                                                          .colorScheme
                                                          .errorContainer;
                                                  if (correctIndex >= 0 &&
                                                      correctIndex <
                                                          _buttonColors
                                                              .length) {
                                                    _buttonColors[correctIndex] =
                                                        correctColor;
                                                  }
                                                });
                                                if (shouldPlaySound) {
                                                  _playSound(
                                                    'assets/audio/wrong.mp3',
                                                  );
                                                }
                                                nextTask(correct: false);
                                              }
                                            }
                                            : null,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
