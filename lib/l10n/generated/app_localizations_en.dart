// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TriviaHQ';

  @override
  String get tabLevels => 'Levels';

  @override
  String get tabCategories => 'Categories';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get statisticsTooltip => 'Statistics';

  @override
  String streakBadge(int count) {
    return '$count day streak';
  }

  @override
  String streakBadgeNew(int count) {
    return '$count day streak!';
  }

  @override
  String streakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String get preparingBank => 'Preparing the question bank';

  @override
  String importProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get couldNotPrepare => 'Could not prepare the quiz data.';

  @override
  String get dailyChallengeTitle => 'Daily challenge';

  @override
  String get dailyChallengeDone => 'Done for today - come back tomorrow';

  @override
  String get dailyChallengeSubtitle =>
      'Ten questions, the same for everyone today';

  @override
  String get practiceTitle => 'Practise your mistakes';

  @override
  String practiceSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions to work on',
      one: '1 question to work on',
    );
    return '$_temp0';
  }

  @override
  String unlockHint(int previous, int next) {
    return 'Beat level $previous to unlock level $next.';
  }

  @override
  String questionCounter(int current, int total) {
    return 'Q: $current/$total';
  }

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String levelSemantics(int number) {
    return 'Level $number';
  }

  @override
  String levelLockedSemantics(int number) {
    return 'Level $number, locked';
  }

  @override
  String get levelWord => 'Level';

  @override
  String get modeDaily => 'Daily challenge';

  @override
  String get modePractice => 'Practice';

  @override
  String get modeLevel => 'Level';

  @override
  String get modeCategory => 'Category';

  @override
  String get noTimeLimit => 'No time limit';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String secondsValue(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get noTimerLabel => 'No timer';

  @override
  String get lifeline5050 => '50:50 - remove two wrong answers';

  @override
  String get lifeline5050Used => '50:50 already used';

  @override
  String get lifelineSkip => 'Skip this question';

  @override
  String get lifelineSkipUsed => 'Skip already used';

  @override
  String lifelineExtraTime(int seconds) {
    return '+$seconds seconds';
  }

  @override
  String get lifelineExtraTimeUsed => 'Extra time already used';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Resume';

  @override
  String get pausedTitle => 'Paused';

  @override
  String get pausedSubtitle => 'Your progress in this round is kept.';

  @override
  String get resume => 'Resume';

  @override
  String get quitRound => 'Quit round';

  @override
  String get exitGameTitle => 'Exit game?';

  @override
  String get exitGameBody =>
      'Do you want to stop the game? Your current progress will be lost.';

  @override
  String get exit => 'Exit';

  @override
  String get continueGame => 'Continue game';

  @override
  String get noQuestions => 'No questions available for this quiz yet.';

  @override
  String get nothingToPractise =>
      'Nothing to practise yet. Play a few rounds and the questions you get wrong will show up here.';

  @override
  String get backToHome => 'Back to home';

  @override
  String get couldNotLoad => 'Could not load questions.';

  @override
  String get resultsTitle => 'Results';

  @override
  String get playAgain => 'Play again';

  @override
  String get home => 'Home';

  @override
  String practiseTheseMistakes(int count) {
    return 'Practise these mistakes ($count)';
  }

  @override
  String get review => 'Review';

  @override
  String allCorrect(int total) {
    return 'All $total correct';
  }

  @override
  String correctOfTotal(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get newBestScore => 'New best score!';

  @override
  String levelUnlocked(int number) {
    return 'Level $number unlocked!';
  }

  @override
  String get couldNotSave => 'Could not save this round';

  @override
  String get verdictCorrect => 'Correct';

  @override
  String get verdictWrong => 'Wrong';

  @override
  String get verdictOutOfTime => 'Out of time';

  @override
  String get verdictSkipped => 'Skipped';

  @override
  String get youAnswered => 'You answered';

  @override
  String get answerLabel => 'Answer';

  @override
  String starRatingSemantics(int earned, int max) {
    return '$earned out of $max stars';
  }

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String bestScore(int score, int total) {
    return 'Best: $score/$total';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionGameplay => 'Gameplay';

  @override
  String get sectionData => 'Data';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get questionsPerRound => 'Questions per round';

  @override
  String questionsPerRoundValue(int count) {
    return '$count questions';
  }

  @override
  String get secondsPerQuestion => 'Seconds per question';

  @override
  String get timerOff => 'Off';

  @override
  String timerSeconds(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsSubtitle =>
      'Play a sound for correct and wrong answers.';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Light haptic feedback when you answer.';

  @override
  String get resetProgressTitle => 'Reset progress';

  @override
  String get resetProgressSubtitle =>
      'Clear scores, unlocks, history and statistics.';

  @override
  String get resetProgressQuestion => 'Reset progress?';

  @override
  String get resetProgressBody =>
      'This clears every level score, re-locks all levels except the first one, clears every category best score and deletes your round history, per-question statistics and streak. It cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get progressReset => 'Progress reset.';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statAccuracy => 'Accuracy';

  @override
  String get statRounds => 'Rounds';

  @override
  String get statBestRound => 'Best round';

  @override
  String get statQuestionsSeen => 'Questions seen';

  @override
  String get statMastered => 'Mastered';

  @override
  String get statToPractise => 'To practise';

  @override
  String get recentRounds => 'Recent rounds';

  @override
  String get noRoundsYet => 'No rounds played yet';

  @override
  String get noRoundsHint =>
      'Finish a level or a category round and your accuracy, best score and hardest questions will show up here.';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryAnimals => 'Animals';

  @override
  String get categoryBrainTeasers => 'Brain teasers';

  @override
  String get categoryCelebrities => 'Celebrities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryGeography => 'Geography';

  @override
  String get categoryHistory => 'History';

  @override
  String get categoryHobbies => 'Hobbies';

  @override
  String get categoryHumanities => 'Humanities';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryLiterature => 'Literature';

  @override
  String get categoryMovies => 'Movies';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryPeople => 'People';

  @override
  String get categoryReligion => 'Religion';

  @override
  String get categoryScienceTechnology => 'Science and Tech';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryTelevision => 'Television';

  @override
  String get categoryVideoGames => 'Video games';

  @override
  String get categoryWorld => 'World';

  @override
  String get byCategory => 'By category';

  @override
  String get hardestQuestions => 'Hardest questions';

  @override
  String accuracyOf(int percent, int correct, int total) {
    return '$percent% ($correct/$total)';
  }

  @override
  String get rebalanceTitle => 'Rebalance campaign';

  @override
  String get rebalanceSubtitle =>
      'Re-order levels by difficulty, using your statistics.';

  @override
  String rebalanceDone(int moved) {
    return 'Campaign rebalanced ($moved questions moved).';
  }

  @override
  String get rebalanceNothing => 'Campaign is already well ordered.';
}
