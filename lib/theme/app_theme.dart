import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final serif = GoogleFonts.cormorantGaramondTextTheme();
    final sans = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.wood,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bronze,
        brightness: Brightness.dark,
      ),
      textTheme: serif.merge(sans),
    );
  }
}
