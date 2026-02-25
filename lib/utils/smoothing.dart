import 'dart:math';

class AngleSmoother {
  // Devuelve el siguiente ángulo siguiendo el camino más corto (evita 359→0 “vuelta larga”).
  static double shortestPathNext(double prevDeg, double newDeg) {
    final diff = ((newDeg - prevDeg + 540) % 360) - 180; // -180..180
    return (prevDeg + diff) % 360;
  }

  // Low-pass smoothing simple: reduce jitter.
  static double lowPass(double prev, double next, double alpha) {
    return prev + alpha * (next - prev);
  }

  static double clamp360(double deg) {
    var v = deg % 360;
    if (v < 0) v += 360;
    return v;
  }

  static double degToRad(double deg) => deg * pi / 180.0;
}
