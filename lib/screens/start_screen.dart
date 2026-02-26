import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

// Pantalla de bienvenida con estilo de pergamino y CTA de inicio.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  // Controla la animacion de fondo de la portada.
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // Animacion lenta y continua para dar movimiento ambiental.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    // Libera el controlador de animacion.
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capas: fondo animado, overlay oscuro, tarjeta central y boton.
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _MovingDesertBackground(
              controller: _ctrl,
              assetPath: 'assets/images/desierto.jpg',
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.22)),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _ParchmentCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 34),

                      Column(
                        children: [
                          Image.asset(
                            'assets/images/ESCUDO-COLOR.png',
                            height: 104, // un poco más grande
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 23),

                          Text(
                            'BRÚJULA DEL\nEXPLORADOR',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.alexBrush(
                              fontSize: 44,
                              height: 1.1,
                              letterSpacing: 1.2,
                              color: AppColors.ink.withOpacity(0.95),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            'Casas Gastelum Ana Cecilia\n'
                            'Murillo Monge Joshua David\n'
                            'Vallejo Leyva Marcos',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 19,
                              height: 1.2,
                              letterSpacing: 0.4,
                              color: AppColors.ink.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),

                      _StartButton(
                        onTap: () => Navigator.pushNamed(context, '/compass'),
                      ),

                      const SizedBox(height: 38),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fondo con desplazamiento y zoom sutil para efecto cinematografico.
class _MovingDesertBackground extends StatelessWidget {
  final AnimationController controller;
  final String assetPath;

  const _MovingDesertBackground({
    required this.controller,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Movimiento orbital suave + ligera variacion de escala.
        final t = controller.value;
        final dx = math.sin(t * 2 * math.pi) * 18;
        final dy = math.cos(t * 2 * math.pi) * 12;
        final scale = 1.10 + (math.sin(t * 2 * math.pi) * 0.02);

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: scale,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  const SizedBox.expand(child: ColoredBox(color: Colors.black)),
            ),
          ),
        );
      },
    );
  }
}

// Tarjeta de pergamino reutilizable para la portada.
class _ParchmentCard extends StatelessWidget {
  final Widget child;
  const _ParchmentCard({required this.child});

  @override
  Widget build(BuildContext context) {
    const radius = 28.0;

    // Estructura decorativa por capas: textura, sombras y bordes.
    return AspectRatio(
      aspectRatio: 3 / 4.5,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEADCC2).withOpacity(0.96),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/parchment.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF000000).withOpacity(0.06),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: const Color(0xFFB89C72).withOpacity(0.90),
                      width: 2.6,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius - 10),
                    border: Border.all(
                      color: const Color(0xFF3A2A1F).withOpacity(0.22),
                      width: 1.3,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(61, 43, 31, 0.40),
                        blurRadius: 46,
                        spreadRadius: -12,
                        offset: Offset(0, 0),
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Boton principal para navegar a la brujula.
class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Boton ornamentado manteniendo area tactil amplia.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEADCC2).withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFB89C72).withOpacity(0.75),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3A2A1F).withOpacity(0.18),
                    width: 1.1,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'INICIAR VIAJE',
                style: GoogleFonts.cinzel(
                  fontSize: 22,
                  height: 1.1,
                  letterSpacing: 2,
                  color: AppColors.ink.withOpacity(0.95),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
