import 'package:geolocator/geolocator.dart';

// Estado de presentacion para la pantalla de brujula.
class CompassState {
  // Estado de permisos/servicios.
  final bool hasPermission;
  final bool locationServiceEnabled;
  final bool sensorSupported;

  // Datos de sensores/ubicacion.
  final double? headingDeg; // 0..360, ya suavizado
  final Position? position;

  const CompassState({
    required this.hasPermission,
    required this.locationServiceEnabled,
    required this.sensorSupported,
    required this.headingDeg,
    required this.position,
  });

  // Atajos para consumo en UI.
  double? get latitude => position?.latitude;
  double? get longitude => position?.longitude;
  double? get altitude => position?.altitude;

  // Copia inmutable para actualizar campos puntuales.
  CompassState copyWith({
    bool? hasPermission,
    bool? locationServiceEnabled,
    bool? sensorSupported,
    double? headingDeg,
    Position? position,
  }) {
    return CompassState(
      hasPermission: hasPermission ?? this.hasPermission,
      locationServiceEnabled:
          locationServiceEnabled ?? this.locationServiceEnabled,
      sensorSupported: sensorSupported ?? this.sensorSupported,
      headingDeg: headingDeg ?? this.headingDeg,
      position: position ?? this.position,
    );
  }
}
