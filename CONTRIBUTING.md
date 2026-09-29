# Contributing

## Setup

```bash
flutter pub get
flutter run
```

Requires a Flutter SDK with Dart `^3.7.2` (Flutter 3.29+), and an Android
device or emulator for `flutter run` — the project has no other platform
target.

## The Isar schemas

The database collections in `lib/models/*.g.dart` are generated and committed.
Whenever you change a model (add a field, add an `@Index`, …), regenerate them
and commit the result:

```bash
dart run build_runner build --delete-conflicting-outputs
```

CI fails when the committed `*.g.dart` files drift from the models.

## Localisation

UI strings live in `lib/l10n/app_en.arb` (English) and `lib/l10n/app_es.arb`
(Spanish); generated code lands in `lib/l10n/generated/`. Run
`flutter gen-l10n` (or just `flutter pub get`) after editing the ARB files.
Use `context.l10n.someString` in the UI, and look category names up by slug via
`context.l10n.categoryLabel(id)`.

## Checks that must pass

```bash
flutter analyze
flutter test
dart format $(git ls-files 'lib' 'test' | grep '\.dart$' | grep -v '\.g\.dart$' | grep -v 'lib/l10n/generated')
```

### Integration tests

`test/integration/` runs against a real Isar instance on the *host* that runs
the test suite (the tests never run on the Android device). It needs a native
Isar library at `build/isar/libisar.so`, which is the Linux build — the same
one CI downloads:

```bash
mkdir -p build/isar
curl -sL -o build/isar/libisar.so \
  https://github.com/isar/isar/releases/download/3.1.0%2B1/libisar_linux_x64.so
flutter test test/integration
```

On other hosts the equivalent file is `libisar.dll` (Windows) or
`libisar.dylib` (macOS). `test/integration/isar_env.dart` only looks for
`libisar.so`, so on those hosts there is no database to run against:
`skipUnlessIsar()` marks the test skipped but the body still runs, so the
integration tests fail with `Bad state: Isar has not been opened yet`. Run them
on Linux, or drop a locally built Isar library in at that path.

## Style

- Pure logic belongs in `lib/utils` and must be unit testable without Flutter
  or Isar.
- Widgets never touch Isar directly; they go through a provider or a
  repository.
- Keep everything `flutter analyze`-clean and formatted with `dart format`.
