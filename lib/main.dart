import 'package:cloud_storage_client/res/fonts.dart';
import 'package:cloud_storage_client/screens/home_tab_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_storage_client/res/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,

      // Light Theme
      theme: ThemeData(
        scaffoldBackgroundColor: MyColors.light,
        colorScheme: const ColorScheme.light(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
        ),
        fontFamily: Fonts.Mulish,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        scaffoldBackgroundColor: MyColors.dark,
        colorScheme: const ColorScheme.dark(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
        ),
        fontFamily: Fonts.Mulish,
      ),

      home: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabLayout();
  }
}

