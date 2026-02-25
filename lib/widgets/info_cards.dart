import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InfoCards extends StatelessWidget {
  final String lat;
  final String lon;
  final String alt;

  const InfoCards({
    super.key,
    required this.lat,
    required this.lon,
    required this.alt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Plate(label: 'LATITUDO', value: lat),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Plate(label: 'LONGITUDO', value: lon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Plate(label: 'ALTITUDO', value: '$alt m'),
        ),
      ],
    );
  }
}

class _Plate extends StatelessWidget {
  final String label;
  final String value;

  const _Plate({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.parchment2.withOpacity(0.40),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // remaches
          Positioned(top: 2, left: 2, child: _dot()),
          Positioned(top: 2, right: 2, child: _dot()),
          Positioned(bottom: 2, left: 2, child: _dot()),
          Positioned(bottom: 2, right: 2, child: _dot()),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2.2,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink.withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.6,
                  color: AppColors.ink.withOpacity(0.95),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 5,
    height: 5,
    decoration: BoxDecoration(
      color: AppColors.ink.withOpacity(0.20),
      shape: BoxShape.circle,
    ),
  );
}
