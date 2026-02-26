import 'package:flutter_compass/flutter_compass.dart';

// Adaptador del plugin de brujula.
class CompassService {
  // Expone el rumbo del sensor como stream nullable.
  Stream<double?> get headingStream {
    // FlutterCompass.events puede emitir null en algunos devices/situaciones.
    return FlutterCompass.events!.map((e) => e.heading);
  }
}
