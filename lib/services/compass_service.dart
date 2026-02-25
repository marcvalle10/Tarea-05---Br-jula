import 'package:flutter_compass/flutter_compass.dart';

class CompassService {
  Stream<double?> get headingStream {
    // FlutterCompass.events puede emitir null en algunos devices/situaciones.
    return FlutterCompass.events!.map((e) => e.heading);
  }
}
