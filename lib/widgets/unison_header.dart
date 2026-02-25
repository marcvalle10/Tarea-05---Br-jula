import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UnisonHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const UnisonHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/ESCUDO-COLOR.png',
          height: 90,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 22),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            height: 1.0,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Container(width: 48, height: 2, color: AppColors.ink.withOpacity(0.20)),
        const SizedBox(height: 12),
        Text(
          subtitle.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 6,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            color: AppColors.ink.withOpacity(0.50),
          ),
        ),
      ],
    );
  }
}
