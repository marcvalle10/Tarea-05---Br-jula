// Formateadores de coordenadas y rumbo para mostrar en UI.
class CoordinateFormatter {
  // Latitud con hemisferio.
  static String lat(double? v) {
    if (v == null) return '--.----';
    final dir = v >= 0 ? 'N' : 'S';
    return '${v.abs().toStringAsFixed(4)}° $dir';
  }

  // Longitud con hemisferio.
  static String lon(double? v) {
    if (v == null) return '--.----';
    final dir = v >= 0 ? 'E' : 'W';
    return '${v.abs().toStringAsFixed(4)}° $dir';
  }

  // Altitud en metros (solo valor).
  static String alt(double? v) {
    if (v == null) return '--';
    return v.toStringAsFixed(0);
  }

  // Rumbo principal en grados enteros.
  static String headingMain(double? v) {
    if (v == null) return '--';
    return v.round().toString();
  }

  // Cardinal aproximado (N, NE, E, ...).
  static String headingCardinal(double? v) {
    if (v == null) return '';
    final d = v % 360;
    const names = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((d + 22.5) / 45).floor() % 8;
    return names[idx];
  }
}
