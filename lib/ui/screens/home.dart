import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trivia/provider/home.dart';
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
  late TabController _tabController;

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

  final _tabs = const ['Levels', 'Categories'];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeProvider = context.watch<HomeProvider>();
    final levels = homeProvider.levels;
    final categories = homeProvider.categories;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        SystemNavigator.pop();
      },
      child:
          homeProvider.showSplash
              ? SplashScreen()
              : Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80,
                  actionsPadding: EdgeInsets.only(right: 16),
                  titleSpacing: 30,
                  title: Text(
                    "TriviaHQ",
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
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
                        tabs: _tabs,
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    levels.isEmpty
                        ? Center(child: CircularProgressIndicator.adaptive())
                        : GridView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: 38,
                            horizontal: 16,
                          ),
                          itemCount: levels.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                mainAxisSpacing: 32,
                                crossAxisSpacing: 16,
                                maxCrossAxisExtent: 150,
                              ),
                          itemBuilder: (context, index) {
                            final level = levels[index];
                            return LevelCard(
                              level: level,
                              onPress:
                                  () => Navigator.pushNamed(
                                    context,
                                    Routes.gameplay,
                                    arguments: level,
                                  ),
                            );
                          },
                        ),
                    categories.isEmpty
                        ? Center(child: CircularProgressIndicator.adaptive())
                        : GridView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          itemCount: categories.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                maxCrossAxisExtent: 175,
                                childAspectRatio: .9,
                              ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryCard(
                              category: category,
                              onPress:
                                  () => Navigator.pushNamed(
                                    context,
                                    Routes.gameplay,
                                    arguments: category,
                                  ),
                            );
                          },
                        ),
                  ],
                ),
              ),
    );
  }
}
