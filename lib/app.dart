import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/start_screen.dart';
import 'screens/compass_screen.dart';

// App raiz: tema global + registro de rutas.
class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuracion base de MaterialApp y navegacion declarativa.
    return MaterialApp(
      title: 'Brújula del Explorador',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const StartScreen(),
            );
          case '/compass':
            return _buildSmoothRoute(
              settings: settings,
              child: const CompassScreen(),
            );
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const StartScreen(),
            );
        }
      },
    );
  }
}

// Transicion reutilizable con fade/slide/scale para cambios de pantalla.
PageRouteBuilder _buildSmoothRoute({
  required RouteSettings settings,
  required Widget child,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}
