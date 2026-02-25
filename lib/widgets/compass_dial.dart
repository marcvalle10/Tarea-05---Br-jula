import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/smoothing.dart';

class CompassDial extends StatefulWidget {
  final double? headingDeg; // ya suavizado (0..360)
  const CompassDial({super.key, required this.headingDeg});

  @override
  State<CompassDial> createState() => _CompassDialState();
}

class _CompassDialState extends State<CompassDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  Animation<double>? _anim;
  double _prev = 0;

  @override
  void didUpdateWidget(covariant CompassDial oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextDeg = widget.headingDeg;
    if (nextDeg == null) return;

    final prev = _prev;
    final next = AngleSmoother.shortestPathNext(prev, nextDeg);
    _prev = AngleSmoother.clamp360(next);

    final from = -AngleSmoother.degToRad(prev);
    final to = -AngleSmoother.degToRad(next);

    _anim = Tween<double>(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          // Rosa rotando
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final a = _anim?.value ?? 0.0;
              return Transform.rotate(
                angle: a,
                child: CustomPaint(
                  size: const Size(320, 320),
                  painter: _WindRosePainter(),
                ),
              );
            },
          ),

          // Aguja estática
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(size: const Size(20, 70), painter: _NeedleTop()),
                Container(
                  width: 2,
                  height: 170,
                  color: Colors.black.withOpacity(0.18),
                ),
                CustomPaint(size: const Size(16, 45), painter: _NeedleBottom()),
              ],
            ),
          ),

          // Tuerca central
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.65),
                  AppColors.bronze.withOpacity(0.85),
                ],
              ),
              border: Border.all(color: Colors.black.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bronze.withOpacity(0.18),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        style: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: fs,
          fontWeight: w,
          color: Colors.black.withOpacity(0.78),
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
