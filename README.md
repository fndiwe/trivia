# TriviaHQ

An offline-first trivia quiz game built with Flutter, Isar and `provider`.

TriviaHQ ships with a ~6 MB question bank (`assets/trivia.json`, 20 categories)
that is imported into a local Isar database on first launch. After that the app
never needs a network connection, an account, or a backend.

## Features

- **Campaign** – a ladder of levels drawn from a shuffled question pool. The
  next level unlocks as soon as you finish the current one.
- **Categories** – free play across 20 topics (Animals, History, Movies,
  Science & Technology, Video games, …).
- **Daily challenge** – ten questions, the same for everyone on a given day,
  plus a streak that grows when you play every day.
- **Practise your mistakes** – questions you get wrong are queued locally and
  offered back as a dedicated practice round.
- **Gameplay** – per-question countdown (or none), three lifelines (50:50,
  skip, +10 seconds), pause, answer review after every round, sound effects and
  haptic feedback.
- **Statistics** – accuracy, rounds played, best round, mastered and
  to-practise questions, recent history.
- **Personalisation** – light/dark/system theme, questions per category round,
  seconds per question (or no timer at all), sound, vibration, reset progress.
- **Localised** – English and Spanish UI (`lib/l10n`).
- **Offline** – no accounts, no network calls, no analytics.

## Screens

| Screen | File |
| --- | --- |
| Home (levels + categories tabs, daily challenge) | `lib/ui/screens/home.dart` |
| Splash / data bootstrap | `lib/ui/screens/splash.dart` |
| Gameplay round | `lib/ui/screens/gameplay.dart` |
| Results + answer review | `lib/ui/screens/result_screen.dart` |
| Statistics | `lib/ui/screens/stats_screen.dart` |
| Settings | `lib/ui/screens/settings.dart` |

## Architecture

```
lib/
  main.dart              app entry point, providers, theming, web guard
  models/                Isar collections + plain data models
                         (Trivia, Level, Category, Settings, QuestionStat,
                         RoundResult) plus generated *.g.dart schemas
  repository/            Isar access: Repository (connection),
                         QuizRepository (selection), StatsRepository,
                         ProgressRepository (rounds, streaks, reset)
  provider/              ChangeNotifier state (HomeProvider, SettingsProvider)
  ui/screens, ui/widgets presentation
  utils/                 pure helpers: scoring, quiz_selection, dates, theme,
                         routes, sound_player, extract_trivia_data
  l10n/                  ARB catalogues + generated AppLocalizations
```

Rules of thumb used in this codebase:

- Anything that can be a pure function lives in `lib/utils` and is unit tested
  without Flutter or Isar (`scoring`, `quiz_selection`, `dates`).
- Widgets never query Isar directly; they go through a provider or a
  repository. Round side effects (unlocking, best scores, streaks) live in
  `ProgressRepository.saveRound`, not in widgets.
- Generated files (`lib/models/*.g.dart`, `lib/l10n/generated/`) are committed.

## Getting started

```bash
flutter pub get
flutter run
```

Requires a Flutter SDK that provides Dart `^3.7.2` (Flutter 3.29 or newer).

### Regenerating code

```bash
# Isar schemas (after changing a model)
dart run build_runner build --delete-conflicting-outputs

# Localisations (after editing lib/l10n/*.arb)
flutter gen-l10n
```

## Tests and static analysis

```bash
flutter analyze
flutter test
```

`test/` contains unit tests for the pure logic, widget tests for the UI, and
`test/integration/` runs the repository layer against a real Isar instance.
The integration tests need the native library (see [CONTRIBUTING.md](CONTRIBUTING.md)
for the one-line download); they skip cleanly when it is absent.

CI runs all of this plus codegen-drift and formatting checks. The pipeline
lives in [`docs/ci.yml`](docs/ci.yml): copy it to `.github/workflows/ci.yml` to
enable it on GitHub.

## Updating the question bank

`assets/trivia.json` is a JSON array of
`{ question, category, answer, choices[] }` objects; `answer` must be one of
`choices`. Bump `currentQuestionBankVersion` in
`lib/utils/extract_trivia_data.dart` when you replace the file — the next
launch detects the mismatch, re-imports the bank and rebuilds the level ladder.

## Roadmap

[SUGGESTIONS.md](SUGGESTIONS.md) lists what has been implemented and what is
still on the table (difficulty-aware campaign, online modes, and more).

## License

MIT, see [LICENSE](LICENSE).
