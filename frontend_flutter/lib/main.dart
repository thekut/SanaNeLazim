import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'providers/user_data_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: const SananeLazimApp(),
    ),
  );
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
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
    );
  }
}