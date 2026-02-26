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

// Pantalla principal de la brujula: consume estado y compone UI.
class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  // Controlador con servicios concretos de sensores/permisos.
  late final CompassController _controller = CompassController(
    compassService: CompassService(),
    locationService: LocationService(),
    permissionService: PermissionService(),
  );

  @override
  void initState() {
    super.initState();
    // Inicia permisos y streams de datos.
    _controller.init();
  }

  @override
  void dispose() {
    // Libera recursos reactivos al salir de pantalla.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Alignment dialAlignment = Alignment(0, 0.08);
    // Estructura principal: fondo animado + estado reactivo + widgets de lectura.
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

                // Carga inicial mientras se publica el primer estado.
                if (s == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Bloqueo duro: sin permiso o sin servicio.
                if (!s.locationServiceEnabled || !s.hasPermission) {
                  return _PermissionBlock(
                    onRetry: () => _controller.refreshPermissions(),
                    onBack: () => Navigator.pop(context),
                    serviceEnabled: s.locationServiceEnabled,
                    hasPermission: s.hasPermission,
                  );
                }

                // Datos formateados para presentar al usuario.
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
                          SizedBox(
                            width: 360,
                            height: 360,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const _LightRing(size: 360),
                                CompassDial(
                                  headingDeg: heading,
                                ), // (320x320) queda centrado por Stack
                              ],
                            ),
                          ),
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

// Barra superior con navegacion y encabezado ornamental.
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Contenedor reutilizable para botones laterales.
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
              style: (tt.labelSmall ?? const TextStyle()).copyWith(
                letterSpacing: 6,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NAUTICUS XVIII',
              style: (tt.labelSmall ?? const TextStyle()).copyWith(
                letterSpacing: 2.6,
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.80),
              ),
            ),
          ],
        ),
        box(const Icon(Icons.anchor_outlined, size: 18, color: AppColors.ink)),
      ],
    );
  }
}

// Lectura destacada de grados y cardinal.
class _HeadingReadout extends StatelessWidget {
  final String heading;
  final String cardinal;

  const _HeadingReadout({required this.heading, required this.cardinal});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Color de brillo para mejorar contraste sobre pergamino.
    final sand = AppColors.parchment.withOpacity(0.90);

    final mainStyle = (tt.displayLarge ?? const TextStyle()).copyWith(
      fontSize: 56,
      fontWeight: FontWeight.w900,
      height: 1.0,
      fontStyle: FontStyle.italic,
      color: AppColors.ink.withOpacity(0.92),
      shadows: [
        Shadow(color: sand.withOpacity(0.35), blurRadius: 14),
        Shadow(color: sand.withOpacity(0.18), blurRadius: 28),
        Shadow(color: Colors.black.withOpacity(0.22), blurRadius: 2),
      ],
    );

    final cardinalStyle = (tt.titleLarge ?? const TextStyle()).copyWith(
      fontSize: 34,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w800,
      letterSpacing: 4,
      color: sand.withOpacity(0.80),
      shadows: [
        Shadow(color: sand.withOpacity(0.40), blurRadius: 16),
        Shadow(color: sand.withOpacity(0.20), blurRadius: 30),
      ],
    );

    return Column(
      children: [
        Container(width: 64, height: 1, color: AppColors.ink.withOpacity(0.20)),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: mainStyle,
            children: [
              TextSpan(text: '$heading° '),
              TextSpan(text: cardinal, style: cardinalStyle),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'RUMBO DE NAVEGACIÓN',
          style: (tt.labelSmall ?? const TextStyle()).copyWith(
            letterSpacing: 6,
            fontStyle: FontStyle.italic,
            color: AppColors.ink.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

// Mensaje de bloqueo cuando faltan permisos/servicio de ubicacion.
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
    final tt = Theme.of(context).textTheme;

    // Mensaje segun la condicion que impide continuar.
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
                color: AppColors.parchment2.withOpacity(0.70),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, color: AppColors.ink),
                  const SizedBox(height: 10),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: (tt.bodyMedium ?? const TextStyle()).copyWith(
                      color: AppColors.ink.withOpacity(0.90),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
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

// Halo decorativo alrededor del dial para reforzar foco visual.
class _LightRing extends StatelessWidget {
  final double size;
  const _LightRing({required this.size});

  @override
  Widget build(BuildContext context) {
    // Colores de halo suaves para resaltar el dial.
    final glow = AppColors.parchment.withOpacity(0.35);
    final glow2 = AppColors.bronze.withOpacity(0.25);

    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // aro + halo
          border: Border.all(
            color: AppColors.parchment2.withOpacity(0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: glow, blurRadius: 26, spreadRadius: 2),
            BoxShadow(color: glow2, blurRadius: 40, spreadRadius: 0),
          ],
        ),
      ),
    );
  }
}
