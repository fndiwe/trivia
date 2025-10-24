import 'package:flutter/material.dart';

class StyledTopTabs extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const StyledTopTabs({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          dividerHeight: 0,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.all(0),
          controller: tabController,
          indicator: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onPrimaryContainer,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
    );
  }
}
