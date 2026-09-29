import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TriviaHQ'**
  String get appTitle;

  /// No description provided for @tabLevels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get tabLevels;

  /// No description provided for @tabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tabCategories;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @statisticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTooltip;

  /// No description provided for @streakBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakBadge(int count);

  /// No description provided for @streakBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak!'**
  String streakBadgeNew(int count);

  /// No description provided for @streakSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String streakSemantics(int count);

  /// No description provided for @preparingBank.
  ///
  /// In en, this message translates to:
  /// **'Preparing the question bank'**
  String get preparingBank;

  /// No description provided for @importProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String importProgress(int done, int total);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @couldNotPrepare.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the quiz data.'**
  String get couldNotPrepare;

  /// No description provided for @dailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge'**
  String get dailyChallengeTitle;

  /// No description provided for @dailyChallengeDone.
  ///
  /// In en, this message translates to:
  /// **'Done for today - come back tomorrow'**
  String get dailyChallengeDone;

  /// No description provided for @dailyChallengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ten questions, the same for everyone today'**
  String get dailyChallengeSubtitle;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practise your mistakes'**
  String get practiceTitle;

  /// No description provided for @practiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question to work on} other{{count} questions to work on}}'**
  String practiceSubtitle(int count);

  /// No description provided for @unlockHint.
  ///
  /// In en, this message translates to:
  /// **'Beat level {previous} to unlock level {next}.'**
  String unlockHint(int previous, int next);

  /// No description provided for @questionCounter.
  ///
  /// In en, this message translates to:
  /// **'Q: {current}/{total}'**
  String questionCounter(int current, int total);

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(int score);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelLabel(int number);

  /// No description provided for @levelSemantics.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelSemantics(int number);

  /// No description provided for @levelLockedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Level {number}, locked'**
  String levelLockedSemantics(int number);

  /// No description provided for @levelWord.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelWord;

  /// No description provided for @modeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge'**
  String get modeDaily;

  /// No description provided for @modePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get modePractice;

  /// No description provided for @modeLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get modeLevel;

  /// No description provided for @modeCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get modeCategory;

  /// No description provided for @noTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'No time limit'**
  String get noTimeLimit;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @secondsValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String secondsValue(int seconds);

  /// No description provided for @noTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'No timer'**
  String get noTimerLabel;

  /// No description provided for @lifeline5050.
  ///
  /// In en, this message translates to:
  /// **'50:50 - remove two wrong answers'**
  String get lifeline5050;

  /// No description provided for @lifeline5050Used.
  ///
  /// In en, this message translates to:
  /// **'50:50 already used'**
  String get lifeline5050Used;

  /// No description provided for @lifelineSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip this question'**
  String get lifelineSkip;

  /// No description provided for @lifelineSkipUsed.
  ///
  /// In en, this message translates to:
  /// **'Skip already used'**
  String get lifelineSkipUsed;

  /// No description provided for @lifelineExtraTime.
  ///
  /// In en, this message translates to:
  /// **'+{seconds} seconds'**
  String lifelineExtraTime(int seconds);

  /// No description provided for @lifelineExtraTimeUsed.
  ///
  /// In en, this message translates to:
  /// **'Extra time already used'**
  String get lifelineExtraTimeUsed;

  /// No description provided for @pauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @resumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTooltip;

  /// No description provided for @pausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedTitle;

  /// No description provided for @pausedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress in this round is kept.'**
  String get pausedSubtitle;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @quitRound.
  ///
  /// In en, this message translates to:
  /// **'Quit round'**
  String get quitRound;

  /// No description provided for @exitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit game?'**
  String get exitGameTitle;

  /// No description provided for @exitGameBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to stop the game? Your current progress will be lost.'**
  String get exitGameBody;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue game'**
  String get continueGame;

  /// No description provided for @noQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions available for this quiz yet.'**
  String get noQuestions;

  /// No description provided for @nothingToPractise.
  ///
  /// In en, this message translates to:
  /// **'Nothing to practise yet. Play a few rounds and the questions you get wrong will show up here.'**
  String get nothingToPractise;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load questions.'**
  String get couldNotLoad;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTitle;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @practiseTheseMistakes.
  ///
  /// In en, this message translates to:
  /// **'Practise these mistakes ({count})'**
  String practiseTheseMistakes(int count);

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @allCorrect.
  ///
  /// In en, this message translates to:
  /// **'All {total} correct'**
  String allCorrect(int total);

  /// No description provided for @correctOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct'**
  String correctOfTotal(int correct, int total);

  /// No description provided for @newBestScore.
  ///
  /// In en, this message translates to:
  /// **'New best score!'**
  String get newBestScore;

  /// No description provided for @levelUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Level {number} unlocked!'**
  String levelUnlocked(int number);

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save this round'**
  String get couldNotSave;

  /// No description provided for @verdictCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get verdictCorrect;

  /// No description provided for @verdictWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get verdictWrong;

  /// No description provided for @verdictOutOfTime.
  ///
  /// In en, this message translates to:
  /// **'Out of time'**
  String get verdictOutOfTime;

  /// No description provided for @verdictSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get verdictSkipped;

  /// No description provided for @youAnswered.
  ///
  /// In en, this message translates to:
  /// **'You answered'**
  String get youAnswered;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answerLabel;

  /// No description provided for @starRatingSemantics.
  ///
  /// In en, this message translates to:
  /// **'{earned} out of {max} stars'**
  String starRatingSemantics(int earned, int max);

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(int count);

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best: {score}/{total}'**
  String bestScore(int score, int total);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionGameplay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get sectionGameplay;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @questionsPerRound.
  ///
  /// In en, this message translates to:
  /// **'Questions per round'**
  String get questionsPerRound;

  /// No description provided for @questionsPerRoundValue.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsPerRoundValue(int count);

  /// No description provided for @secondsPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Seconds per question'**
  String get secondsPerQuestion;

  /// No description provided for @timerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get timerOff;

  /// No description provided for @timerSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String timerSeconds(int seconds);

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a sound for correct and wrong answers.'**
  String get soundEffectsSubtitle;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light haptic feedback when you answer.'**
  String get vibrationSubtitle;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear scores, unlocks, history and statistics.'**
  String get resetProgressSubtitle;

  /// No description provided for @resetProgressQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get resetProgressQuestion;

  /// No description provided for @resetProgressBody.
  ///
  /// In en, this message translates to:
  /// **'This clears every level score, re-locks all levels except the first one, clears every category best score and deletes your round history, per-question statistics and streak. It cannot be undone.'**
  String get resetProgressBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @progressReset.
  ///
  /// In en, this message translates to:
  /// **'Progress reset.'**
  String get progressReset;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statAccuracy;

  /// No description provided for @statRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get statRounds;

  /// No description provided for @statBestRound.
  ///
  /// In en, this message translates to:
  /// **'Best round'**
  String get statBestRound;

  /// No description provided for @statQuestionsSeen.
  ///
  /// In en, this message translates to:
  /// **'Questions seen'**
  String get statQuestionsSeen;

  /// No description provided for @statMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get statMastered;

  /// No description provided for @statToPractise.
  ///
  /// In en, this message translates to:
  /// **'To practise'**
  String get statToPractise;

  /// No description provided for @recentRounds.
  ///
  /// In en, this message translates to:
  /// **'Recent rounds'**
  String get recentRounds;

  /// No description provided for @noRoundsYet.
  ///
  /// In en, this message translates to:
  /// **'No rounds played yet'**
  String get noRoundsYet;

  /// No description provided for @noRoundsHint.
  ///
  /// In en, this message translates to:
  /// **'Finish a level or a category round and your accuracy, best score and hardest questions will show up here.'**
  String get noRoundsHint;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get categoryAnimals;

  /// No description provided for @categoryBrainTeasers.
  ///
  /// In en, this message translates to:
  /// **'Brain teasers'**
  String get categoryBrainTeasers;

  /// No description provided for @categoryCelebrities.
  ///
  /// In en, this message translates to:
  /// **'Celebrities'**
  String get categoryCelebrities;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get categoryGeography;

  /// No description provided for @categoryHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get categoryHistory;

  /// No description provided for @categoryHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get categoryHobbies;

  /// No description provided for @categoryHumanities.
  ///
  /// In en, this message translates to:
  /// **'Humanities'**
  String get categoryHumanities;

  /// No description provided for @categoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// No description provided for @categoryLiterature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get categoryLiterature;

  /// No description provided for @categoryMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get categoryMovies;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get categoryPeople;

  /// No description provided for @categoryReligion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get categoryReligion;

  /// No description provided for @categoryScienceTechnology.
  ///
  /// In en, this message translates to:
  /// **'Science and Tech'**
  String get categoryScienceTechnology;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryTelevision.
  ///
  /// In en, this message translates to:
  /// **'Television'**
  String get categoryTelevision;

  /// No description provided for @categoryVideoGames.
  ///
  /// In en, this message translates to:
  /// **'Video games'**
  String get categoryVideoGames;

  /// No description provided for @categoryWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get categoryWorld;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @hardestQuestions.
  ///
  /// In en, this message translates to:
  /// **'Hardest questions'**
  String get hardestQuestions;

  /// No description provided for @accuracyOf.
  ///
  /// In en, this message translates to:
  /// **'{percent}% ({correct}/{total})'**
  String accuracyOf(int percent, int correct, int total);

  /// No description provided for @rebalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Rebalance campaign'**
  String get rebalanceTitle;

  /// No description provided for @rebalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-order levels by difficulty, using your statistics.'**
  String get rebalanceSubtitle;

  /// No description provided for @rebalanceDone.
  ///
  /// In en, this message translates to:
  /// **'Campaign rebalanced ({moved} questions moved).'**
  String rebalanceDone(int moved);

  /// No description provided for @rebalanceNothing.
  ///
  /// In en, this message translates to:
  /// **'Campaign is already well ordered.'**
  String get rebalanceNothing;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @shareResultText.
  ///
  /// In en, this message translates to:
  /// **'I scored {score}/{total} on {mode} in TriviaHQ. Can you beat me?'**
  String shareResultText(int score, int total, String mode);

  /// No description provided for @shareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing isn\'t available on this device.'**
  String get shareUnavailable;

  /// No description provided for @starsOf.
  ///
  /// In en, this message translates to:
  /// **'{stars} out of 3 stars'**
  String starsOf(int stars);

  /// No description provided for @canYouBeatMe.
  ///
  /// In en, this message translates to:
  /// **'Can you beat me?'**
  String get canYouBeatMe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
