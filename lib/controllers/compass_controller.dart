import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';

import '../models/compass_state.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../utils/smoothing.dart';

// Orquesta permisos, sensores y ubicacion para exponer un estado unificado.
class CompassController {
  // Dependencias de infraestructura.
  final CompassService compassService;
  final LocationService locationService;
  final PermissionService permissionService;

  // Estado reactivo consumido por la UI.
  final _state = BehaviorSubject<CompassState>();

  Stream<CompassState> get stream => _state.stream;

  StreamSubscription? _sub;
  double? _lastHeading; // para shortest path + smoothing
  bool _disposed = false;

  CompassController({
    required this.compassService,
    required this.locationService,
    required this.permissionService,
  });

  // Inicializa permisos, publica estado inicial y conecta streams.
  Future<void> init() async {
    final serviceEnabled = await permissionService.isLocationServiceEnabled();
    final hasPerm = await permissionService.ensureLocationReady();

    // Estado inicial
    _state.add(
      CompassState(
        hasPermission: hasPerm,
        locationServiceEnabled: serviceEnabled,
        sensorSupported: true,
        headingDeg: null,
        position: null,
      ),
    );

    if (!serviceEnabled || !hasPerm) {
      // No iniciamos streams si no hay permisos/servicio.
      return;
    }

    // Stream de rumbo con normalizacion y suavizado.
    final heading$ = compassService.headingStream
        .where((v) => v != null)
        .cast<double>()
        .map(AngleSmoother.clamp360)
        // 30 FPS aprox. para evitar saltos bruscos y dar animación consistente
        .throttleTime(const Duration(milliseconds: 33), trailing: true)
        .map<double?>((raw) {
          final prev = _lastHeading ?? raw;

          // Camino corto (evita 359→0 “vuelta larga”).
          final nextShortest = AngleSmoother.shortestPathNext(prev, raw);

          // Smoothing adaptativo: menos jitter cuando hay ruido, pero responde rápido si giras fuerte.
          final alpha = AngleSmoother.adaptiveAlpha(prev, nextShortest);
          final smooth = AngleSmoother.lowPass(prev, nextShortest, alpha);

          _lastHeading = AngleSmoother.clamp360(smooth);
          return _lastHeading;
        })
        .onErrorReturn(null);

    // Stream de ubicacion con tolerancia a errores.
    final pos$ = locationService.positionStream
        .map<Position?>((p) => p) // <-- lo vuelves Position?
        .onErrorReturn(null);
    // Combina rumbo + posicion en un solo estado para la pantalla.
    _sub =
        Rx.combineLatest2<double?, Position?, CompassState>(heading$, pos$, (
          h,
          p,
        ) {
          final cur = _state.valueOrNull;
          return (cur ??
                  const CompassState(
                    hasPermission: true,
                    locationServiceEnabled: true,
                    sensorSupported: true,
                    headingDeg: null,
                    position: null,
                  ))
              .copyWith(headingDeg: h, position: p);
        }).listen(
          (s) {
            if (_disposed) return;
            _state.add(s);
          },
          onError: (_) {
            if (_disposed) return;
            final cur = _state.valueOrNull;
            if (cur != null) _state.add(cur.copyWith(sensorSupported: false));
          },
        );
  }

  // Revalida permisos/servicio cuando el usuario reintenta.
  Future<void> refreshPermissions() async {
    final serviceEnabled = await permissionService.isLocationServiceEnabled();
    final hasPerm = await permissionService.ensureLocationReady();
    final cur = _state.valueOrNull;
    if (cur != null) {
      _state.add(
        cur.copyWith(
          hasPermission: hasPerm,
          locationServiceEnabled: serviceEnabled,
        ),
      );
    }
  }

  // Libera suscripciones y cierra el stream interno.
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _state.close();
  }
}
