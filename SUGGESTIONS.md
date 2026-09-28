# Roadmap

Status of the improvement list. Items that shipped are checked and moved to the
top; the rest is what is still on the table.

---

## Shipped

- [x] **Answer review after a round** – every question is shown with the
  player's answer, the correct answer and a verdict (correct / wrong / out of
  time / skipped), reachable from `result_screen.dart`.
- [x] **Daily challenge and streaks** – date-seeded ten questions, identical on
  every device, plus a day streak tracked in settings and shown on the home
  screen. Statistics screen (accuracy, rounds, best round, mastered and
  to-practise questions, recent history).
- [x] **Practise your mistakes** – a `QuestionStat` collection (keyed by
  question text so it survives re-imports) feeds a dedicated practice round and
  the practice queue count on the home screen.
- [x] **Lifelines** – 50:50, skip and +10 seconds, one each per round, with an
  explicit `ChoiceStatus.eliminated` state.
- [x] **Pause / resume** – an overlay that hides the question; the countdown
  also pauses when the app is backgrounded.
- [x] **Accessibility** – grids grow with the font size, confetti and the level
  animation respect "reduce motion", and the main widgets announce clean
  `Semantics` labels.
- [x] **Localisation** – English and Spanish, with a 20-key category name
  lookup by slug (`lib/l10n`, `context.l10n`).
- [x] **Web fails gracefully** – a clear "not available on the web" screen
  instead of a crash.
- [x] **Startup import on a background isolate** – the 6 MB question bank is
  parsed in `compute()` with a determinate progress bar on the splash screen.
- [x] **Testable repositories** – `test/integration/` runs the whole
  repository layer against a real Isar instance with a seeded bank (selection,
  unlocks, best scores, streaks, practice queue, reset).
- [x] **Audio pipeline** – clips are preloaded once in a `SoundPlayer` instead
  of being re-read from disk on every answer.
- [x] **License** – MIT.
- [x] **CONTRIBUTING.md** – setup, codegen, localisation and check instructions.
- [x] **Asset/category consistency test** – every category slug has an SVG icon
  and vice versa.
- [x] **CI** – pipeline in `docs/ci.yml` (analyze, format, codegen drift,
  localisation drift, integration lib, tests). Copy it to
  `.github/workflows/ci.yml` from your account; the automation identity used
  for this branch is not allowed to push workflow files.

---

## Still on the table

### 1. Difficulty-aware campaign — **L**

Levels are still a fixed shuffle-and-chunk partition. With the `QuestionStat`
data that now exists you can estimate per-question difficulty and rebuild the
ladder with a real progression curve (easiest questions first). This is the one
suggestion that changes the game's shape, so it deserves its own design pass:
how many levels, when to re-balance, and what happens to existing level scores
when the ladder is re-partitioned.

### 2. Richer per-category statistics — **M**

The stats screen shows global numbers. Per-category accuracy and a "hardest
questions" list (sorted by accuracy from `QuestionStat`) would make it much
more useful. Both are now cheap: the data is already stored.

### 3. Shareable result card — **M**

The offline-first constraint rules out a server leaderboard, but a shareable
image/text card of a good result is most of the social value without a backend.

### 4. Icons and native splash — **S**

`flutter_launcher_icons` and `flutter_native_splash`, once there is a source
logo asset. The config is intentionally not committed without one, because a
missing asset makes those generators fail.

### 5. Release configuration — **S/M**

Android signing config, `--split-per-abi`, ProGuard/R8 rules for Isar and
just_audio, and `CFBundleDisplayName` on iOS.

### 6. More languages — **S each**

Drop a new `app_<locale>.arb` into `lib/l10n` (copy `app_en.arb`), run
`flutter gen-l10n`, and the app picks it up automatically. The question bank
itself is English-only, so a meaningful new language also needs translated
questions.

## Deliberately not recommended

- **Ads, accounts and server-side leaderboards.** Offline-first is this app's
  main advantage; the result card (item 3) covers most of the social value.
- **Adding another state-management library.** `provider` plus the current
  small provider classes is sufficient at this size.
