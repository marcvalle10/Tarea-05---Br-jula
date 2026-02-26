import 'dart:math';

// Utilidades para normalizar y suavizar angulos de brujula.
class AngleSmoother {
  // Devuelve el siguiente ángulo siguiendo el camino más corto (evita 359→0 “vuelta larga”).
  static double shortestPathNext(double prevDeg, double newDeg) {
    final diff = ((newDeg - prevDeg + 540) % 360) - 180; // -180..180
    return (prevDeg + diff) % 360;
  }

  // Low-pass smoothing simple: reduce jitter.
  // Filtro pasa-bajas basico.
  static double lowPass(double prev, double next, double alpha) {
    return prev + alpha * (next - prev);
  }


  /// Alpha adaptativo (0.08..0.35) en función del delta entre prev y next.
  /// - deltas pequeños -> alpha bajo (más suavizado)
  /// - deltas grandes -> alpha alto (responde más rápido)
  static double adaptiveAlpha(double prevDeg, double nextDeg) {
    final diff = (((nextDeg - prevDeg + 540) % 360) - 180).abs(); // 0..180
    // Normaliza: 0..90° -> 0..1 (satura después)
    final t = (diff / 90).clamp(0.0, 1.0);
    return (0.08 + (0.35 - 0.08) * t);
  }

  // Normaliza cualquier angulo al rango [0, 360).
  static double clamp360(double deg) {
    var v = deg % 360;
    if (v < 0) v += 360;
    return v;
  }

  // Conversion util para pintores/canvas.
  static double degToRad(double deg) => deg * pi / 180.0;
}
