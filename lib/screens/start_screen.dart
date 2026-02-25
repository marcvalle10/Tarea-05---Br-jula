import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/unison_header.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        mode: BackgroundMode.splash,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _ParchmentCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 34),
                    const UnisonHeader(
                      title: 'Brújula del\nExplorador',
                      subtitle:
                          'Casas Gastelum Ana Cecilia\n'
                          'Murillo Monge Joshua David\n'
                          'Vallejo Leyva Marcos',
                    ),
                    const SizedBox(height: 10),
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
      ),
    );
  }
}

class _ParchmentCard extends StatelessWidget {
  final Widget child;
  const _ParchmentCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(61, 43, 31, 0.55),
                      blurRadius: 40,
                      spreadRadius: -10,
                      offset: Offset(0, 0),
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          border: Border.all(
            color: AppColors.ink.withOpacity(0.40),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.ink.withOpacity(0.10),
                    width: 0.8,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'INICIAR VIAJE',
                style: TextStyle(
                  color: AppColors.ink.withOpacity(0.95),
                  fontSize: 10,
                  letterSpacing: 4.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
