# 🧭 Brújula del Explorador

Aplicación móvil desarrollada en Flutter que implementa sensores reales del dispositivo para mostrar la orientación (brújula digital) y la ubicación en tiempo real, integrando un diseño inspirado en mapas cartográficos antiguos.

# 👨‍💻 Autores

Marcos Vallejo
Cecilia Casas
Joshua Murillo

# Descripción

Brújula del Explorador es una aplicación móvil funcional que:

Detecta la orientación del dispositivo utilizando el magnetómetro.

Muestra los grados en tiempo real.

Indica puntos cardinales.

Obtiene coordenadas GPS en tiempo real.

Presenta un diseño temático tipo cartografía antigua (mapas náuticos estilo siglo XVII–XVIII).

Implementa animaciones suaves y filtros de estabilización de datos.

El proyecto fue desarrollado como parte de la Tarea 05 – Brújula.

# 🛠 Tecnologías Utilizadas
# Desarrollo

Flutter SDK (3.x)

Dart (3.x)

Arquitectura modular por capas

# Sensores y Funcionalidad

flutter_compass → Lectura del magnetómetro

geolocator → Ubicación GPS en tiempo real

permission_handler → Gestión de permisos

AnimationController → Animaciones

Filtro de suavizado personalizado (smoothing)

# Diseño

Material Design

Google Fonts:

Great Vibes

Allura

Uncial Antiqua

Assets personalizados:

Texturas tipo pergamino

Fondo estilo mapa antiguo

Componentes reutilizables

# 🔧 Control de Versiones

Git

GitHub

# 📂 Estructura del Proyecto (lib/)
lib/
│
├── main.dart
├── app.dart
│
├── theme/
│   ├── app_colors.dart
│   └── app_theme.dart
│
├── screens/
│   ├── start_screen.dart
│   └── compass_screen.dart
│
├── widgets/
│   ├── animated_background.dart
│   ├── compass_dial.dart
│   ├── info_cards.dart
│   └── unison_header.dart
│
├── services/
│   ├── compass_service.dart
│   ├── location_service.dart
│   └── permission_service.dart
│
├── controllers/
│   └── compass_controller.dart
│
├── models/
│   └── compass_state.dart
│
└── utils/
    ├── smoothing.dart
    └── formatters.dart

# 📸 Imágenes de la Aplicación

Agrega aquí capturas reales:

/assets/screenshots/start_screen.png
/assets/screenshots/compass_screen.png
/assets/screenshots/location_cards.png

Y luego en el README:

### Icono de app
![Icon App](assets/screenshots/app_icon.png)

### Vista de Inicio
![Start Screen](assets/screenshots/start_screen.png)

### Vista Brújula
![Compass Screen](assets/screenshots/compass_screen.png)

### Ubicación en Tiempo Real
![Location](assets/screenshots/location_cards.png)
📦 Release 1.0

La versión estable de la aplicación se encuentra en:

👉 Releases → v1.0

APK instalable para Android

Compilado en modo release

Para generar el APK:

flutter build apk --release

El archivo generado se encuentra en:

build/app/outputs/flutter-apk/app-release.apk


🚀 Cómo Ejecutar el Proyecto
flutter pub get
flutter run

