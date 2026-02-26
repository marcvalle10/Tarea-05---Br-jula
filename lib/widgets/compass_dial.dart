import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

// Widget del dial de brujula con rosa, aguja y animacion de giro.
class CompassDial extends StatefulWidget {
  final double? headingDeg; // ya suavizado (0..360)
  const CompassDial({super.key, required this.headingDeg});

  @override
  State<CompassDial> createState() => _CompassDialState();
}

class _CompassDialState extends State<CompassDial> {
  // turns acumulado para que AnimatedRotation no “salte” al cruzar 0/360.
  double _turns = 0.0;
  double? _prevDeg;

  @override
  void didUpdateWidget(covariant CompassDial oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Convierte el cambio angular en delta corto y acumula vueltas.
    final nextDeg = widget.headingDeg;
    if (nextDeg == null) return;

    final prev = _prevDeg ?? nextDeg;
    final delta = (((nextDeg - prev + 540) % 360) - 180); // -180..180
    _prevDeg = nextDeg;

    // El dial rota en sentido contrario al heading (como antes: angle = -degToRad()).
    // Convertimos delta en turns acumulados.
    setState(() {
      _turns += (-delta / 360.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Capas del dial: lineas, rosa, aguja y letra cardinal fija.
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rayos/loxodromas fijos (detrás)
          IgnorePointer(
            child: CustomPaint(
              size: const Size(320, 320),
              painter: _RadialLinesPainter(),
            ),
          ),

          // Rosa rotando (animación implícita)
          AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: CustomPaint(
              size: const Size(320, 320),
              painter: _WindRosePainter(),
            ),
          ),

          // Aguja estática
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(size: const Size(20, 70), painter: _NeedleTop()),
                const SizedBox(height: 10),
                CustomPaint(size: const Size(20, 70), painter: _NeedleBottom()),
              ],
            ),
          ),

          // Texto N fijo
          Positioned(
            top: 16,
            child: Text(
              'N',
              style: GoogleFonts.uncialAntiqua(
                fontSize: 24,
                color: AppColors.ink.withOpacity(0.9),
                shadows: [
                  Shadow(
                    color: AppColors.glowSand.withOpacity(0.28),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lineas radiales de fondo (loxodromas decorativas).
class _RadialLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    final glow = Paint()
      ..color = AppColors.bronze.withOpacity(0.12)
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final p = Paint()
      ..color = Colors.black.withOpacity(0.22)
      ..strokeWidth = 0.8;

    for (var i = 0; i < 16; i++) {
      final ang = i * (pi / 16);
      final dir = Offset(cos(ang), sin(ang));
      canvas.drawLine(c - dir * 320, c + dir * 320, glow);
      canvas.drawLine(c - dir * 320, c + dir * 320, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pintor principal de la rosa de los vientos.
class _WindRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final ringGlow = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.bronze.withOpacity(0.14)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.30)
      ..strokeWidth = 1.2;

    canvas.drawCircle(c, r - 2, ringGlow);
    canvas.drawCircle(c, r - 2, ring);

    canvas.drawCircle(
      c,
      r - 12,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withOpacity(0.12)
        ..strokeWidth = 2.0,
    );

    // Graduaciones (ticks) + glow suave
    final tickGlow = Paint()
      ..color = AppColors.bronze.withOpacity(0.12)
      ..strokeWidth = 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final tick = Paint()..color = Colors.black.withOpacity(0.40);

    for (var i = 0; i < 72; i++) {
      final ang = i * (2 * pi / 72);
      final isMajor = i % 9 == 0;
      final isMid = i % 3 == 0;

      final len = isMajor ? 18.0 : (isMid ? 10.0 : 6.0);
      tick.strokeWidth = isMajor ? 1.6 : 0.9;
      tickGlow.strokeWidth = tick.strokeWidth + 1.6;

      final a = Offset(cos(ang), sin(ang));
      final p1 = c + a * (r - 8);
      final p2 = c + a * (r - 8 - len);

      canvas.drawLine(p1, p2, tickGlow);
      canvas.drawLine(p1, p2, tick);
    }

    // Estrella: 4 puntas principales (bronce, borde oscuro, glow)
    _spike(canvas, c, 0, 95, 34, isMain: true);
    _spike(canvas, c, pi / 2, 95, 34, isMain: true);
    _spike(canvas, c, pi, 95, 34, isMain: true);
    _spike(canvas, c, 3 * pi / 2, 95, 34, isMain: true);

    // Puntas intermedias más discretas (oscuro con glow leve)
    for (final ang in [pi / 4, 3 * pi / 4, 5 * pi / 4, 7 * pi / 4]) {
      _spike(canvas, c, ang, 70, 22, isMain: false);
    }

    // Letras cardinales (negro + glow bronce)
    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    void drawText(String s, Offset pos, double fs, FontWeight w) {
      tp.text = TextSpan(
        text: s,
        style: GoogleFonts.uncialAntiqua(
          fontSize: fs,
          fontWeight: w,
          color: AppColors.ink.withOpacity(0.92),
          shadows: [
            Shadow(color: AppColors.bronze.withOpacity(0.22), blurRadius: 10),
            Shadow(color: Colors.black.withOpacity(0.22), blurRadius: 2),
          ],
        ),
      );
      tp.layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    drawText('N', c + const Offset(0, -120), 28, FontWeight.w900);
    drawText('S', c + const Offset(0, 120), 22, FontWeight.w800);
    drawText('E', c + const Offset(130, 0), 22, FontWeight.w800);
    drawText('W', c + const Offset(-130, 0), 22, FontWeight.w800);

    // Centro decorativo (borde oscuro + glow)
    final centerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.bronze.withOpacity(0.12)
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final centerRing = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.28)
      ..strokeWidth = 1;

    canvas.drawCircle(c, 12, centerGlow);
    canvas.drawCircle(c, 12, centerRing);
  }

  void _spike(
    Canvas canvas,
    Offset c,
    double ang,
    double length,
    double width, {
    required bool isMain,
  }) {
    // Dibuja una punta principal o secundaria de la rosa.
    final dir = Offset(cos(ang), sin(ang));
    final ort = Offset(-sin(ang), cos(ang));
    final tip = c + dir * length;
    final base = c + dir * 22;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + ort.dx * (width / 2), base.dy + ort.dy * (width / 2))
      ..lineTo(base.dx - ort.dx * (width / 2), base.dy - ort.dy * (width / 2))
      ..close();

    if (isMain) {
      // Glow
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.bronze.withOpacity(0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Fill bronce
      canvas.drawPath(
        path,
        Paint()..color = AppColors.bronze.withOpacity(0.85),
      );
      // Borde oscuro
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.black.withOpacity(0.30),
      );
    } else {
      // Glow leve
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.bronze.withOpacity(0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Fill oscuro
      canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.35));
      // Borde
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.black.withOpacity(0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Mitad superior de la aguja (bronce).
class _NeedleTop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // aguja superior (bronce) + borde oscuro
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.bronze.withOpacity(0.90)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    canvas.drawPath(path, Paint()..color = AppColors.bronze.withOpacity(0.85));

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withOpacity(0.25),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Mitad inferior de la aguja (contraste oscuro).
class _NeedleBottom extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.35));

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withOpacity(0.22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
