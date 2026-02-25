import 'package:geolocator/geolocator.dart';

class LocationService {
  Stream<Position> get positionStream {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
