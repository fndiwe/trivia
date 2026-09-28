import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/models/quiz_request.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/ui/screens/splash.dart';
import 'package:trivia/ui/widgets/category_card.dart';
import 'package:trivia/ui/widgets/daily_challenge_card.dart';
import 'package:trivia/ui/widgets/level_card.dart';
import 'package:trivia/ui/widgets/styled_top_tabs.dart';
import 'package:trivia/utils/dates.dart';
import 'package:trivia/utils/routes.dart';
import 'package:trivia/l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;
    // Hand the back gesture to the OS on mobile so the app can be closed;
    // on desktop/web the root route simply stays put.
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeProvider = context.watch<HomeProvider>();
    final streak = context.select<SettingsProvider, int>(
      (provider) => provider.settings.currentStreak,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child:
          homeProvider.showSplash
              ? const SplashScreen()
              : Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80,
                  actionsPadding: const EdgeInsets.only(right: 12),
                  titleSpacing: 30,
                  title: Text(
                    'TriviaHQ',
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    if (streak > 0) StreakBadge(streak: streak),
                    IconButton(
                      tooltip: context.l10n.statisticsTooltip,
                      icon: const Icon(Icons.insights_outlined),
                      onPressed:
                          () => Navigator.of(context).pushNamed(Routes.stats),
                    ),
                    IconButton(
                      tooltip: context.l10n.settingsTooltip,
                      icon: const Icon(Icons.settings),
                      onPressed:
                          () =>
                              Navigator.of(context).pushNamed(Routes.settings),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(55),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        left: 38,
                        right: 38,
                      ),
                      child: StyledTopTabs(
                        tabController: _tabController,
                        tabs: [
                          context.l10n.tabLevels,
                          context.l10n.tabCategories,
                        ],
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: const [_LevelsTab(), _CategoriesTab()],
                ),
              ),
    );
  }
}

/// Level grid, preceded by the daily challenge and the practice entry point.
class _LevelsTab extends StatelessWidget {
  const _LevelsTab();

  @override
  Widget build(BuildContext context) {
    final levels = context.watch<HomeProvider>().levels;
    if (levels.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final practiceCount = context.select<HomeProvider, int>(
      (provider) => provider.practiceCount,
    );
    final dailyDone = context.select<SettingsProvider, bool>((provider) {
      final done = provider.settings.dailyChallengeCompletedOn;
      return done != null && isSameLocalDay(done, DateTime.now());
    });
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.list(
            children: [
              DailyChallengeCard(
                done: dailyDone,
                onPlay:
                    () => Navigator.of(context).pushNamed(
                      Routes.gameplay,
                      arguments: const QuizRequest.daily(),
                    ),
              ),
              if (practiceCount > 0) ...[
                const SizedBox(height: 12),
                PracticeCard(
                  count: practiceCount,
                  onPlay:
                      () => Navigator.of(context).pushNamed(
                        Routes.gameplay,
                        arguments: const QuizRequest.practice(),
                      ),
                ),
              ],
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          sliver: SliverGrid.builder(
            itemCount: levels.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisSpacing: 32,
              crossAxisSpacing: 16,
              maxCrossAxisExtent: 150,
              // Grow the cells with the user's font size instead of letting the
              // pentagon labels overflow at large accessibility scales.
              mainAxisExtent: (150 * scale).clamp(150, 240),
            ),
            itemBuilder: (context, index) {
              final level = levels[index];
              return LevelCard(
                level: level,
                onPress: () => _openLevel(context, level),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openLevel(BuildContext context, Level level) {
    if (!level.isUnlocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(context.l10n.unlockHint(level.id - 1, level.id)),
          ),
        );
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(Routes.gameplay, arguments: QuizRequest.level(level));
  }
}

/// Category grid. The star rating is scaled to the round length the player
/// picked in settings, and capped by how many questions the category has.
class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<HomeProvider>().categories;
    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final roundSize = context.select<SettingsProvider, int>(
      (provider) => provider.settings.categoryRoundSize,
    );
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        maxCrossAxisExtent: 175,
        mainAxisExtent: (190 * scale).clamp(190, 320),
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          roundSize: roundSize,
          onPress: () => _openCategory(context, category),
        );
      },
    );
  }

  void _openCategory(BuildContext context, Category category) {
    Navigator.of(
      context,
    ).pushNamed(Routes.gameplay, arguments: QuizRequest.category(category));
  }
}
