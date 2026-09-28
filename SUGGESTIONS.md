# What to build next

A prioritised list of improvements for TriviaHQ. Each item says *why* it is
worth doing, roughly how big it is, and which files it touches.

Legend: **S** ≈ under a day, **M** ≈ a few days, **L** ≈ a week or more.

---

## Already improved in this pass

For context, so the list below does not repeat them:

- the round is now a single state machine (`lib/ui/screens/gameplay.dart`) — the
  countdown no longer restarts forever after the last question, no longer
  advances questions while the app is backgrounded, and a timeout reveals the
  answer instead of silently skipping it;
- levels draw **random** questions per round instead of the same ten rows in id
  order, and both `Trivia.level` and `Category.categoryId` are indexed;
- answer choices are reshuffled per question so the correct answer is not always
  in the authored slot;
- routing (`lib/utils/routes.dart`) has a fallback and no longer crashes on
  unknown route names;
- `RatingStars` cannot divide by zero while questions are still loading;
- new settings (questions per round, seconds per question or no timer, haptics,
  reset progress) persisted through `SettingsProvider`;
- the question bank is re-imported when `currentQuestionBankVersion` changes;
- 47 unit/widget tests plus a CI pipeline (`docs/ci.yml`).

---

## Next up (highest value for the least work)

### 1. Answer review after a round — **M**

After each round, list every question with the player's answer, the correct
answer and a link back to the category. This is the single biggest learning win:
right now the results screen only shows `score/total`.

- Pass the answered questions to `ResultScreen` (it already receives `score`
  and `total`; add a `List<AnsweredQuestion>`), or persist the round in a new
  Isar collection so it can be revisited from the home screen.
- Reuse `GameChoiceButton` with `ChoiceStatus.correct` / `.wrong` to render the
  rows, so the review looks identical to the game.

### 2. Streaks, daily challenge and "best" stats — **M**

Retention is the whole point of a trivia app; a reason to come back tomorrow
beats any amount of polish.

- `DailyChallenge`: derive a seed from the date
  (`Random(2026 * 10000 + month * 100 + day)`) and reuse `pickRandom` in
  `lib/utils/quiz_selection.dart` so every device gets the same ten questions.
- Streak: add `lastPlayedOn` and `currentStreak` to the `Settings` collection
  and show a flame badge on the home screen.
- Stats screen: questions answered, accuracy per category, hardest category.

### 3. Practise your mistakes (spaced repetition) — **M**

Add a `QuestionStat` collection (`questionId`, `timesShown`, `timesCorrect`,
`lastSeen`) written from `_revealAnswer`. With that data you can:

- build a "Practice mistakes" mode from the home screen;
- stop repeating questions the player already knows;
- estimate question difficulty and use it to order the campaign, which would let
  levels be generated rather than frozen at import time.

### 4. Lifelines — **S/M**

50:50, skip and +10 seconds, granted once or twice per round. Cheap to build on
top of `_revealAnswer`, and it adds real decisions to a round. Requires a small
amount of UI in `GameHeader` plus state in `_GamePlayScreenState`.

### 5. Pause / resume a round — **S**

Exit is currently the only way out of a round, and it always discards progress.
A pause overlay (the same pattern as `_showExitDialog`, which already suspends
the countdown) would let players stop without losing the round.

### 6. Accessibility and large text — **S/M**

- Text scaling: the level and category grids use fixed `mainAxisSpacing` and
  `childAspectRatio`, so large accessibility fonts will overflow. Prefer
  flexible heights, and test the home screen at `TextScaler.linear(2)`.
- `MediaQuery.disableAnimations`: skip `ConfettiBurst` and the level highlight
  animation when the platform asks for reduced motion.
- High-contrast mode: `Colors.green` for a correct answer is defined in
  `AppColors.correct`; check it against `colorScheme.surface` in both themes.
- `Semantics` coverage is partially done (`RatingStars`, `GameChoiceButton`,
  `LevelCard`); the category grid and the countdown still need labels.

### 7. Localisation — **M**

`intl` is already a dependency but nothing is localised. Add
`flutter_localizations`, extract the UI strings into `lib/l10n/app_en.arb`, and
translate the 20 category names. `Categories.categories` already keeps
`categoryId` separate from the display name, so the asset lookup
(`assets/images/<categoryId>.svg`) survives translation.


---

## Bigger bets

### 8. Web and desktop support — **M**

`main()` calls `getApplicationDocumentsDirectory()`, which throws on web, yet
`web/` is a generated platform folder. Either:

- guard the directory with `kIsWeb` and open Isar with a web backend (Isar 3 web
  support is experimental), or
- fall back to a `shared_preferences`/JSON cache on web, or
- delete the `web/` folder so nobody assumes it works.

Also check that `just_audio` and haptics degrade gracefully on desktop.

### 9. Startup import performance — **M**

`assets/trivia.json` is 6.3 MB (~10k questions) and is parsed on the UI isolate
on first launch. If start-up feels slow:

- run the parse in `compute()` and stream progress into the splash screen;
- ship a gzipped/binary asset, or split it per category and import lazily;
- show real progress (`Questions 4,000 / 10,120`) instead of a spinner.

Measure first: wrap `extractDataToDatabase()` in a `Stopwatch` behind
`kDebugMode`.

### 10. Testing beyond pure functions — **M**

The repository layer (`QuizRepository`, `ProgressRepository`) currently reaches
for the global `Repository.isar` singleton, which makes it untestable. Pass the
`Isar` instance into the repositories (or use `isar_test`) so round logic,
unlocking and score persistence can be covered end to end, and add an
`integration_test/` case for "play a level to the end and see the results".

### 11. Audio pipeline — **S**

Every answer calls `setAsset()` then `play()`, which re-reads the file and can
lag behind the tap. Preload the five short clips into a small `AudioPlayer` pool
(or a `ConcatenatingAudioSource`) and reuse them. Also wire up the currently
unused `assets/audio/click.mp3` for button feedback, and consider a mute toggle
directly in `GameHeader`.

### 12. Difficulty-aware campaign — **L**

The ladder is "shuffle everything, chunk by 10", so level 1 can contain brutal
questions. With per-question statistics (item 3) you can order the campaign by
empirical difficulty and give each level a real progression curve.

---

## Housekeeping (quick wins)

- **License** — the repository has none. Add one before sharing it publicly.
- **`CONTRIBUTING.md`** — or at least a PR template carrying the "regenerate the
  Isar schemas" note from the README.
- **App icon and native splash** — `flutter_launcher_icons` and
  `flutter_native_splash`, so the branding matches the in-app splash screen.
- **Release configuration** — Android signing config, `--split-per-abi`,
  ProGuard/R8 rules for Isar and just_audio, and `CFBundleDisplayName` on iOS.
- **Move the CI file into place** — `.github/workflows/ci.yml` could not be
  pushed by the automation identity used for this branch (GitHub App tokens need
  the `workflows` scope). Copy `docs/ci.yml` there and push from your account.
- **Asset/category consistency** — images are addressed by convention
  (`assets/images/<categoryId>.svg`). If a category is renamed, nothing catches
  the missing file; add a start-up assertion that every entry in
  `Categories.categories` has a matching asset.

## Deliberately not recommended

- **Ads, accounts and server-side leaderboards.** Offline-first is this app's
  main advantage; a device-local leaderboard or a shareable result card gets
  most of the social value without a backend.
- **Adding another state-management library.** `provider` plus the current small
  provider classes is sufficient at this size.
