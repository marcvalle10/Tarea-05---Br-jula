import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Construye el ThemeData global de la app.
class AppTheme {
  // Mezcla tipografias, colores y estilos de componentes.
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.ink,
      brightness: Brightness.light,
    );

    // Base: lectura (serif antiguo, legible)
    final body = GoogleFonts.imFellEnglishTextTheme(base.textTheme);

    // Headings: estilo medieval (decorativo)
    final headings = GoogleFonts.uncialAntiquaTextTheme(base.textTheme);

    // Mezcla: todo cuerpo en IM Fell; headings en Uncial
    final mixed = body.copyWith(
      displayLarge: headings.displayLarge,
      displayMedium: headings.displayMedium,
      displaySmall: headings.displaySmall,
      headlineLarge: headings.headlineLarge,
      headlineMedium: headings.headlineMedium,
      headlineSmall: headings.headlineSmall,
      titleLarge: headings.titleLarge,
      titleMedium: headings.titleMedium,
      titleSmall: headings.titleSmall,
    );

    // Ajuste de tamaños/weights (más consistente y “pro” en móvil)
    final tuned = mixed.copyWith(
      displayLarge: (mixed.displayLarge ?? const TextStyle()).copyWith(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: AppColors.ink,
      ),
      headlineMedium: (mixed.headlineMedium ?? const TextStyle()).copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: AppColors.ink,
      ),
      titleLarge: (mixed.titleLarge ?? const TextStyle()).copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleMedium: (mixed.titleMedium ?? const TextStyle()).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: (mixed.bodyLarge ?? const TextStyle()).copyWith(
        fontSize: 16,
        height: 1.35,
        color: AppColors.ink,
      ),
      bodyMedium: (mixed.bodyMedium ?? const TextStyle()).copyWith(
        fontSize: 14,
        height: 1.35,
        color: AppColors.ink,
      ),
      labelSmall: (mixed.labelSmall ?? const TextStyle()).copyWith(
        fontSize: 11,
        letterSpacing: 2.6,
        fontWeight: FontWeight.w700,
        color: AppColors.ink.withOpacity(0.62),
      ),
    );

    // Resultado final aplicado en MaterialApp.
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: tuned,

      // Botones / labels respetan tipografía global
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: tuned.titleMedium,
          foregroundColor: AppColors.ink,
        ),
      ),
    );
  }
}
