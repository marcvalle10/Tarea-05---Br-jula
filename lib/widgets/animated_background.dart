import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Fondo animado reutilizable para splash y pantalla de brujula.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final BackgroundMode mode;

  /// Alineación del “foco” del mapa (para centrar el círculo detrás del dial)
  /// Ej: Alignment(0, -0.10) sube un poco el mapa.
  final Alignment mapAlignment;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.mode,
    this.mapAlignment = Alignment.center,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

// Variante visual del fondo segun pantalla.
enum BackgroundMode { splash, compass }

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  // Anima particulas/polvo del fondo.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    // Libera animacion de fondo.
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasWood = widget.mode == BackgroundMode.splash;

    // Capas: base, mapa (opcional), vignette, particulas y contenido.
    return Stack(
      clipBehavior: Clip.none, // CLAVE: evita recorte al rotar/cover
      children: [
        // Base
        Positioned.fill(
          child: hasWood
              ? Image.asset(
                  'assets/images/wood_bg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.wood),
                )
              : Container(color: Colors.black),
        ),

        // MAPA (modo brújula): cover real + centrado + rotación vertical
        if (widget.mode == BackgroundMode.compass)
          Positioned.fill(
            child: Opacity(
              opacity: 0.86,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final h = c.maxHeight;

                  // RotatedBox intercambia ancho/alto en layout (más estable que Transform.rotate)
                  return Align(
                    alignment: widget.mapAlignment,
                    child: RotatedBox(
                      quarterTurns: 3, // -90° para vertical
                      child: SizedBox(
                        width: h, // por rotación
                        height: w,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset('assets/images/orbis_map.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Vignette
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  AppColors.ink.withOpacity(0.25),
                  Colors.black.withOpacity(0.65),
                ],
                stops: const [0.55, 0.80, 1.0],
              ),
            ),
          ),
        ),

        // Partículas/polvo
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final t = _c.value;
                return CustomPaint(painter: _DustPainter(t: t));
              },
            ),
          ),
        ),

        widget.child,
      ],
    );
  }
}

// Pintor de polvo ambiente con desplazamiento horizontal continuo.
class _DustPainter extends CustomPainter {
  final double t;
  _DustPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Particulas pseudoaleatorias deterministas para evitar allocations extras.
    final paint = Paint()..color = AppColors.parchment2.withOpacity(0.03);
    for (var i = 0; i < 70; i++) {
      final dx = (size.width * ((i * 37) % 100) / 100.0) + (t * 120);
      final x = (dx % (size.width + 40)) - 20;
      final y = size.height * (((i * 53) % 100) / 100.0);
      canvas.drawCircle(Offset(x, y), (i % 3 + 1).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) => oldDelegate.t != t;
}
