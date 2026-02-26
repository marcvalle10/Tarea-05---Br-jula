import 'package:flutter/material.dart';
import 'app.dart';

// Punto de entrada de la aplicacion.
// Inicializa bindings y monta el widget raiz.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CompassApp());
}
