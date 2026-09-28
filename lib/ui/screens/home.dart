import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/provider/settings.dart';
import 'package:trivia/ui/screens/splash.dart';
import 'package:trivia/ui/widgets/category_card.dart';
import 'package:trivia/ui/widgets/level_card.dart';
import 'package:trivia/ui/widgets/styled_top_tabs.dart';
import 'package:trivia/utils/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['Levels', 'Categories'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: homeProvider.showSplash
          ? const SplashScreen()
          : Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 80,
                actionsPadding: const EdgeInsets.only(right: 16),
                titleSpacing: 30,
                title: Text(
                  'TriviaHQ',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings),
                    onPressed: () =>
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
                      tabs: _tabs,
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

/// Level grid. Locked levels explain how to unlock instead of silently doing
/// nothing when tapped.
class _LevelsTab extends StatelessWidget {
  const _LevelsTab();

  @override
  Widget build(BuildContext context) {
    final levels = context.watch<HomeProvider>().levels;
    if (levels.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 16),
      itemCount: levels.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 32,
        crossAxisSpacing: 16,
        maxCrossAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        final level = levels[index];
        return LevelCard(
          level: level,
          onPress: () => _openLevel(context, level),
        );
      },
    );
  }

  void _openLevel(BuildContext context, Level level) {
    if (!level.isUnlocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Beat level ${level.id - 1} to unlock level ${level.id}.',
            ),
          ),
        );
      return;
    }
    Navigator.of(context).pushNamed(Routes.gameplay, arguments: level);
  }
}

/// Category grid. The star rating is scaled to the round length the player
/// picked in settings, and capped by how many questions the category has.
class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<HomeProvider>().categories;
    final roundSize = context.select<SettingsProvider, int>(
      (provider) => provider.settings.categoryRoundSize,
    );
    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        maxCrossAxisExtent: 175,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          roundSize: roundSize,
          onPress: () => Navigator.of(
            context,
          ).pushNamed(Routes.gameplay, arguments: category),
        );
      },
    );
  }
}

