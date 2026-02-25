import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:geolocator/geolocator.dart';

import '../models/compass_state.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../utils/smoothing.dart';

class CompassController {
  final CompassService compassService;
  final LocationService locationService;
  final PermissionService permissionService;

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

    final heading$ = compassService.headingStream
        .where((v) => v != null)
        .cast<double>()
        .map(AngleSmoother.clamp360)
        .throttleTime(const Duration(milliseconds: 60), trailing: true)
        .map<double?>((raw) {
          // <-- OJO: ahora devuelve double?
          final prev = _lastHeading ?? raw;
          final nextShortest = AngleSmoother.shortestPathNext(prev, raw);
          final smooth = AngleSmoother.lowPass(prev, nextShortest, 0.20);
          _lastHeading = AngleSmoother.clamp360(smooth);
          return _lastHeading; // <-- ya no uses !
        })
        .onErrorReturn(null);

    final pos$ = locationService.positionStream
        .map<Position?>((p) => p) // <-- lo vuelves Position?
        .onErrorReturn(null);
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

  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _state.close();
  }
}
