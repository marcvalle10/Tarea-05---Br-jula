import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

// Gestiona permisos de ubicacion y accesos a ajustes.
class PermissionService {
  // Verifica servicio GPS y solicita permiso si hace falta.
  Future<bool> ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    final req = await Permission.locationWhenInUse.request();
    return req.isGranted;
  }

  // Consulta rapida del estado del servicio de ubicacion.
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  // Abre ajustes del sistema para que el usuario cambie permisos.
  Future<void> openSettings() => openAppSettings();
}
