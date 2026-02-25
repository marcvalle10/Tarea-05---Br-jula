import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  Future<bool> ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    final req = await Permission.locationWhenInUse.request();
    return req.isGranted;
  }

  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  Future<void> openSettings() => openAppSettings();
}
