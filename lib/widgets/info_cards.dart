import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Tarjetas con lecturas de latitud, longitud y altitud.
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
    // Distribuye tres placas en una fila responsiva.
    return Row(
      children: [
        Expanded(
          child: _Plate(
            icon: Icons.location_on_outlined,
            label: 'LATITUDO',
            value: lat,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Plate(
            icon: Icons.near_me_outlined,
            label: 'LONGITUDO',
            value: lon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Plate(
            icon: Icons.crop_free_outlined,
            label: 'ALTITUDO',
            value: '$alt m',
          ),
        ),
      ],
    );
  }
}

// Placa individual con icono, etiqueta y valor.
class _Plate extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Plate({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Efecto vidrio/pergamino con remaches decorativos.
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.parchment.withOpacity(0.22), // “vidrio” claro
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // remaches (más finos)
              Positioned(top: 6, left: 6, child: _pin()),
              Positioned(top: 6, right: 6, child: _pin()),
              Positioned(bottom: 6, left: 6, child: _pin()),
              Positioned(bottom: 6, right: 6, child: _pin()),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: AppColors.bronze.withOpacity(0.70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: (tt.labelSmall ?? const TextStyle()).copyWith(
                      letterSpacing: 3.0,
                      fontStyle: FontStyle.italic,
                      color: AppColors.ink.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: (tt.titleMedium ?? const TextStyle()).copyWith(
                      fontSize: 18,
                      height: 1.0,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink.withOpacity(0.92),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Remache decorativo.
  Widget _pin() => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      color: AppColors.ink.withOpacity(0.18),
      shape: BoxShape.circle,
    ),
  );
}
