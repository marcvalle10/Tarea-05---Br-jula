import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/start_screen.dart';
import 'screens/compass_screen.dart';

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brújula del Explorador',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: {
        '/': (_) => const StartScreen(),
        '/compass': (_) => const CompassScreen(),
      },
      initialRoute: '/',
    );
  }
}
