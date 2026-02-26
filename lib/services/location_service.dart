import 'package:geolocator/geolocator.dart';

// Adaptador de geolocalizacion continua.
class LocationService {
  // Stream de posicion con maxima precision.
  Stream<Position> get positionStream {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
