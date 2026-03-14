import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const SananeLazimApp());
}

class SananeLazimApp extends StatelessWidget {
  const SananeLazimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SananeLazım',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Zorunlu Dark Mode desteği
      home: const WelcomeScreen(),
    );
  }
}
