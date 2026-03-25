import 'package:flutter/material.dart';
import 'package:table_game_bot/screens/game_selection_screen.dart';
import 'package:table_game_bot/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Game Bot',
      theme: AppTheme.cuteTheme,
      home: const GameSelectionScreen(),
    );
  }
}
