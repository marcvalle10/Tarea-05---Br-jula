import 'package:flutter/material.dart';
import '../controllers/compass_controller.dart';
import '../models/compass_state.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/animated_background.dart';
import '../widgets/compass_dial.dart';
import '../widgets/info_cards.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  late final CompassController _controller = CompassController(
    compassService: CompassService(),
    locationService: LocationService(),
    permissionService: PermissionService(),
  );

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Alignment dialAlignment = Alignment(0, 0.08);
    return Scaffold(
      body: AnimatedBackground(
        mode: BackgroundMode.compass,
        mapAlignment: dialAlignment, // NUEVO
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: StreamBuilder<CompassState>(
              stream: _controller.stream,
              builder: (context, snap) {
                final s = snap.data;

                if (s == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Bloqueo duro: sin permiso o sin servicio
                if (!s.locationServiceEnabled || !s.hasPermission) {
                  return _PermissionBlock(
                    onRetry: () => _controller.refreshPermissions(),
                    onBack: () => Navigator.pop(context),
                    serviceEnabled: s.locationServiceEnabled,
                    hasPermission: s.hasPermission,
                  );
                }

                final heading = s.headingDeg;
                final headingText = CoordinateFormatter.headingMain(heading);
                final cardinal = CoordinateFormatter.headingCardinal(heading);

                return Column(
                  children: [
                    _TopBar(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 22),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CompassDial(headingDeg: heading),
                          const SizedBox(height: 22),
                          _HeadingReadout(
                            heading: headingText,
                            cardinal: cardinal,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    InfoCards(
                      lat: CoordinateFormatter.lat(s.latitude),
                      lon: CoordinateFormatter.lon(s.longitude),
                      alt: CoordinateFormatter.alt(s.altitude),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    Widget box(Widget child) => Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.parchment2.withOpacity(0.60),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(child: child),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onBack,
          child: box(
            const Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
          ),
        ),
        Column(
          children: [
            Text(
              'INSTRUMENTUM',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 6,
                fontStyle: FontStyle.italic,
                color: AppColors.ink.withOpacity(0.60),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NAUTICUS XVIII',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: Colors.black.withOpacity(0.75),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        box(const Icon(Icons.anchor_outlined, size: 18, color: AppColors.ink)),
      ],
    );
  }
}

class _HeadingReadout extends StatelessWidget {
  final String heading;
  final String cardinal;

  const _HeadingReadout({required this.heading, required this.cardinal});

  @override
  Widget build(BuildContext context) {
    final arena = AppColors.parchment.withOpacity(0.85);

    return Column(
      children: [
        Container(width: 64, height: 1, color: AppColors.ink.withOpacity(0.20)),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 56,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.78),
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(color: arena.withOpacity(0.35), blurRadius: 14),
                Shadow(color: arena.withOpacity(0.18), blurRadius: 28),
                Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 2),
              ],
            ),
            children: [
              TextSpan(text: '$heading° '),
              TextSpan(
                text: cardinal,
                style: TextStyle(
                  fontSize: 34,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: arena.withOpacity(0.75),
                  shadows: [
                    Shadow(color: arena.withOpacity(0.40), blurRadius: 16),
                    Shadow(color: arena.withOpacity(0.20), blurRadius: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'RUMBO DE NAVEGACIÓN',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 6,
            fontStyle: FontStyle.italic,
            color: AppColors.ink.withOpacity(0.40),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PermissionBlock extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final bool serviceEnabled;
  final bool hasPermission;

  const _PermissionBlock({
    required this.onRetry,
    required this.onBack,
    required this.serviceEnabled,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {
    final msg = !serviceEnabled
        ? 'Activa el servicio de ubicación (GPS) para continuar.'
        : 'Permite ubicación “Mientras se usa” para ver latitud/longitud/altitud.';

    return Column(
      children: [
        _TopBar(onBack: onBack),
        const SizedBox(height: 28),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.parchment2.withOpacity(0.65),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, color: AppColors.ink),
                  const SizedBox(height: 10),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink.withOpacity(0.85),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
