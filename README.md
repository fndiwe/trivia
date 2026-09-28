# TriviaHQ

An offline-first trivia quiz game built with Flutter, Isar and `provider`.

TriviaHQ ships with a ~6 MB question bank (`assets/trivia.json`, 20 categories)
that is imported into a local Isar database on first launch. After that the app
never needs a network connection.

## Features

- **Campaign** – a ladder of levels, each drawn from a shuffled pool of
  questions. The next level unlocks as soon as you finish the current one.
- **Categories** – free play across 20 topics (Animals, History, Movies,
  Science & Technology, Video games, …).
- **Gameplay** – per-question countdown, three-star rating, animated answer
  reveal, sound effects and haptic feedback.
- **Settings** – light/dark/system theme, questions per category round, seconds
  per question (or no timer at all), sound, vibration and a reset-progress
  action.
- **Offline** – no accounts, no network calls, no analytics.

## Screens

| Screen | File |
| --- | --- |
| Home (levels + categories tabs) | `lib/ui/screens/home.dart` |
| Splash / data bootstrap | `lib/ui/screens/splash.dart` |
| Gameplay round | `lib/ui/screens/gameplay.dart` |
| Results | `lib/ui/screens/result_screen.dart` |
| Settings | `lib/ui/screens/settings.dart` |

## Architecture

```
lib/
  main.dart              app entry point, providers, theming
  models/                Isar collections (Trivia, Level, Category, Settings)
                         plus generated *.g.dart schemas
  repository/            Isar access: Repository (connection), QuizRepository
                         (question selection), ProgressRepository (reset)
  provider/              ChangeNotifier state (HomeProvider, SettingsProvider)
  ui/screens, ui/widgets presentation
  utils/                 pure helpers: scoring, quiz_selection, theme, routes,
                         categories, extract_trivia_data
```

Rules of thumb used in this codebase:

- Anything that can be written as a pure function lives in `lib/utils` and is
  unit tested without Flutter or Isar (`lib/utils/scoring.dart`,
  `lib/utils/quiz_selection.dart`).
- Widgets never query Isar directly; they go through a provider or a repository.
- Generated files (`lib/models/*.g.dart`) are committed, because the Isar
  schemas define the on-disk format.

## Getting started

```bash
flutter pub get
flutter run
```

Requires a Flutter SDK that provides Dart `^3.7.2` (Flutter 3.29 or newer).

### Regenerating the Isar schemas

The `*.g.dart` files are generated from the annotations in `lib/models`. After
changing a collection (adding a field, adding an `@Index`, …) run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Tests and static analysis

```bash
flutter analyze
flutter test
dart format $(git ls-files 'lib' 'test' | grep '\.dart$' | grep -v '\.g\.dart$')
```

CI (`.github/workflows/ci.yml`) runs exactly these steps, and also fails when
the generated schemas are out of date.

## Updating the question bank

`assets/trivia.json` is a JSON array of
`{ question, category, answer, choices[] }` objects; `answer` must be one of
`choices`. Bump `currentQuestionBankVersion` in
`lib/utils/extract_trivia_data.dart` when you replace the file — the next launch
detects the mismatch, re-imports the bank and rebuilds the level ladder.

## Roadmap

See [SUGGESTIONS.md](SUGGESTIONS.md) for the prioritised list of what to build
next (review screen, daily challenge, streaks, localisation, …).
