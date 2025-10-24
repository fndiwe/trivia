import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trivia/models/level.dart';
import 'package:trivia/provider/home.dart';
import 'package:trivia/repository/repository.dart';
import 'package:trivia/utils/extract_trivia_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() async {
    final isar = Repository.isar;
    final count = await isar.levels.count();
    Future.delayed(const Duration(seconds: 2), () async {
      if (count < 1) {
        await extractDataToDatabase();
        _launchTask();
      } else {
        _launchTask();
      }
    });
    super.didChangeDependencies();
  }

  void _launchTask() {
    final homeProvider = context.read<HomeProvider>();
    homeProvider.loadLevels();
    homeProvider.loadCategories();
    homeProvider.changeShowSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "TriviaHQ",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
