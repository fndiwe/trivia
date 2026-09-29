# Roadmap

Everything that was on the improvement list has now shipped; what remains are
the small finishing touches. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
workflow.

---

## Shipped

**Gameplay and progression**
- **Difficulty-aware campaign** – every question gets an intrinsic difficulty
  score (question length, how confusable the wrong choices are, whether the
  answer is numeric), so level 1 is genuinely the easiest on a fresh install.
  As the player answers questions, the score is blended with their observed
  accuracy (`posteriorDifficulty`), and the ladder is re-partitioned at most
  once a day once there are 50+ answers. Unlocks are preserved by rank, so a
  rebalance never takes progress away. Also available as a manual
  "Rebalance campaign" action in settings.
- **Daily challenge and streaks** – ten date-seeded questions, identical on
  every device, plus a day streak tracked in settings.
- **Practise your mistakes** – a `QuestionStat` collection (keyed by question
  text so it survives re-imports) feeds a dedicated practice round.
- **Lifelines** – 50:50, skip, +10 seconds, one each per round.
- **Pause/resume** – an overlay that hides the question; the countdown also
  pauses when the app is backgrounded.
- **Answer review after every round** – each question with the player's answer,
  the correct answer and a verdict.

**Insight**
- **Statistics screen** – accuracy, rounds, best round, mastered and
  to-practise questions, and recent history.
- **Per-category accuracy** – a "By category" breakdown, worst first, with a
  tap-to-play shortcut.
- **Hardest questions** – the lowest-accuracy questions (with a minimum sample
  size so a single unlucky answer does not dominate).

**Sharing**
- **Shareable result card** – the results screen renders a 360x560 card (score
  ring, stars, streak, date) and hands it to the system share sheet as a PNG
  via `share_plus`, with a text-only fallback. The button is hidden on Linux
  and Windows, where `share_plus` has no implementation.

**Foundations**
- Localisation (English and Spanish), accessibility (font-scale-aware grids,
  "reduce motion", clean `Semantics`), question-bank import on a background
  isolate with a determinate progress bar, preloaded audio clips, graceful
  web guard, MIT license, CONTRIBUTING, CI pipeline (`docs/ci.yml`), and 123
  unit / widget / integration tests.

---

## Still on the table

### 1. Icons and native splash — **S**

`flutter_launcher_icons` and `flutter_native_splash`, once there is a source
logo asset. The config is intentionally not committed without one, because a
missing asset makes those generators fail.

### 2. Release configuration — **S/M**

Android signing config, `--split-per-abi`, ProGuard/R8 rules for Isar,
`share_plus` and `just_audio`, and `CFBundleDisplayName` on iOS.

### 3. More languages — **S each**

Drop a new `app_<locale>.arb` into `lib/l10n` (copy `app_en.arb`), run
`flutter gen-l10n`, and the app picks it up automatically. The question bank
itself is English-only, so a meaningful new language also needs translated
questions.

### 4. Difficulty prior tuning — **M**

The difficulty weights (30% length, 50% distractor similarity, 20% numeric
  answer, and the `alpha` smoothing) in `lib/utils/difficulty.dart` are sensible
  defaults, not fitted constants. If the campaign ever feels badly ordered, the
  honest fix is to tune them against real data: record which level a question
  was answered at, and fit the weights so early levels really are the ones
  players get right.

## Deliberately not recommended

- **Ads, accounts and server-side leaderboards.** Offline-first is this app's
  main advantage; the shareable result card covers most of the social value
  without a backend.
- **Adding another state-management library.** `provider` plus the current
  small provider classes is sufficient at this size.
