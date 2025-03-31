# QR Scanner App con Autenticación Biométrica

Una aplicación Flutter moderna que combina seguridad biométrica con funcionalidad de escaneo QR, implementando las últimas tendencias en UI/UX para 2025.

![Flutter Version](https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-android-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## 🌟 Características Principales

### 🔐 Autenticación Segura
- Autenticación biométrica nativa (Huella digital/Face ID)
- Fallback a PIN de 4 dígitos
- Implementación segura usando BiometricPrompt
- Manejo de estados de autenticación

### 📱 Escaneo QR Avanzado
- Implementación nativa con CameraX
- Almacenamiento local con SQLite
- Historial de escaneos con timestamps

### 🎨 Diseño Moderno
- Implementación de tendencias UI/UX 2025
- Glassmorphism y efectos de profundidad
- Animaciones y transiciones fluidas

### 🏗️ Arquitectura
- Clean Architecture
- BLoC para gestión de estado
- Integración nativa con Pigeon
- Código nativo en Kotlin
- Tests unitarios completos

## 📋 Requisitos Previos

- Flutter SDK ≥ 3.0.0
- Android Studio o VS Code con plugins de Flutter
- Android SDK con soporte para API 21+
- Dispositivo Android con soporte biométrico

## 🚀 Inicio Rápido

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/baalcoder/qr_auth_app.git
   cd qr_auth_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar código necesario**
   ```bash
   # Generar código Pigeon
   flutter pub run pigeon --input pigeons/auth_qr_api.dart
   
   # Generar mocks para tests
   flutter pub run build_runner build
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🛠️ Configuración del Proyecto

### Estructura del Proyecto

```
qr_auth_app/
├── android/                        # Código nativo de Android
│   ├── app/
│   │   └── src/main/
│   │       ├── kotlin/            # Implementaciones nativas
│   │       │   └── com/example/qr_auth_app/
│   │       │       ├── AuthQrPlugin.kt          # Plugin principal
│   │       │       ├── BiometricHelper.kt       # Lógica biométrica
│   │       │       ├── QRScannerHelper.kt       # Lógica de CameraX
│   │       │       └── MainActivity.kt          # Actividad principal
│   │       └── AndroidManifest.xml # Configuración Android
│   ├── build.gradle.kts           # Configuración Gradle (Kotlin DSL)
│   └── settings.gradle.kts        # Configuración del proyecto
│
├── lib/
│   ├── core/                      # Funcionalidad central
│   │   ├── database/
│   │   │   └── database_helper.dart  # Configuración SQLite
│   │   ├── theme/
│   │   │   └── app_theme.dart     # Temas y estilos globales
│   │   └── widgets/
│   │       ├── custom_tooltip.dart # Tooltips personalizados
│   │       └── info_card.dart     # Tarjetas informativas
│   │
│   ├── features/                  # Módulos principales
│   │   ├── auth/                  # Feature de autenticación
│   │   │   ├── data/             # Capa de datos
│   │   │   ├── domain/           # Lógica de negocio
│   │   │   └── presentation/     # UI y estado
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       ├── pages/
│   │   │       │   └── auth_page.dart
│   │   │       └── widgets/
│   │   │           └── pin_dialog.dart
│   │   │
│   │   └── qr_scanner/           # Feature de escaneo QR
│   │       ├── data/             # Capa de datos
│   │       ├── domain/           # Lógica de negocio
│   │       │   └── models/
│   │       │       └── qr_code.dart
│   │       └── presentation/     # UI y estado
│   │           ├── bloc/
│   │           │   ├── qr_scanner_bloc.dart
│   │           └── pages/
│   │               └── qr_scanner_page.dart
│   │
│   └── main.dart                 # Punto de entrada
│
├── pigeons/                      # Definiciones de Pigeon
│   └── auth_qr_api.dart         # Interface nativa-Flutter
│
├── test/                        # Pruebas unitarias
│   ├── features/
│   │   ├── auth/
│   │   │   └── bloc/
│   │   │       └── auth_bloc_test.dart
│   │   └── qr_scanner/
│   │       ├── bloc/
│   │       │   └── qr_scanner_bloc_test.dart
│   │       └── domain/
│   │           └── models/
│   │               └── qr_code_test.dart
│   └── widget_test.dart
│
├── pubspec.yaml                 # Dependencias y configuración
├── README.md                    # Documentación
└── LICENSE                      # Licencia MIT
```

#### 📁 Descripción de Directorios

##### 🛠 Android
- `kotlin/`: Implementaciones nativas en Kotlin
  - `AuthQrPlugin.kt`: Plugin principal que conecta Flutter con Android
  - `BiometricHelper.kt`: Manejo de autenticación biométrica
  - `QRScannerHelper.kt`: Implementación de CameraX para escaneo QR
  - `MainActivity.kt`: Configuración de la actividad principal

##### 📱 Lib
###### Core
- `database/`: Configuración y helpers para SQLite
- `theme/`: Definición de estilos y temas globales
- `widgets/`: Componentes reutilizables en toda la app

###### Features
Cada feature sigue Clean Architecture con tres capas:

**Auth Feature**
- `data/`: Implementación de repositorios y fuentes de datos
- `domain/`: Entidades y casos de uso
- `presentation/`: 
  - `bloc/`: Manejo de estado con BLoC
  - `pages/`: Pantallas principales
  - `widgets/`: Componentes específicos

**QR Scanner Feature**
- Similar estructura a Auth, pero enfocado en escaneo QR
- Incluye modelo de datos QR y lógica de almacenamiento

##### 🔄 Pigeons
- Definiciones de la interfaz entre Flutter y código nativo
- Genera código para comunicación segura y tipada

##### 🧪 Test
- Pruebas unitarias organizadas por feature
- Sigue la misma estructura que el código fuente
- Incluye mocks y helpers de testing

#### 🔍 Puntos Clave de la Arquitectura

1. **Separación de Responsabilidades**
   - Código nativo aislado en `android/`
   - Lógica de negocio en `domain/`
   - UI y estado en `presentation/`

2. **Modularidad**
   - Features independientes
   - Core compartido
   - Widgets reutilizables

3. **Testing**
   - Estructura espejo para pruebas
   - Fácil navegación y mantenimiento
   - Cobertura completa

4. **Integración Nativa**
   - Pigeon para comunicación segura
   - Implementaciones Kotlin optimizadas
   - Separación clara de responsabilidades

### Configuración Android

1. **Permisos requeridos** (AndroidManifest.xml):
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.USE_BIOMETRIC" />
   ```

2. **Configuración de Gradle**:
   - Kotlin DSL implementado
   - Soporte para CameraX
   - Configuración BiometricPrompt

## 🧪 Testing

La aplicación incluye un conjunto completo de pruebas unitarias:

```bash
# Ejecutar todas las pruebas
flutter test

# Ejecutar pruebas específicas
flutter test test/features/auth/bloc/auth_bloc_test.dart
flutter test test/features/qr_scanner/bloc/qr_scanner_bloc_test.dart
```

## 📱 Características de la UI

### Pantalla de Autenticación
- Diseño moderno con glassmorphism
- Animaciones suaves
- Tooltips informativos
- Feedback visual inmediato

### Pantalla de Escaneo
- Vista de cámara con bordes animados
- Lista de códigos escaneados con diseño moderno
- Gestos para eliminar códigos
- Feedback en tiempo real

## 🔒 Seguridad

- Implementación segura de BiometricPrompt
- Almacenamiento seguro de PIN
- Manejo seguro de datos biométricos
- No almacenamiento de datos sensibles

## 🎯 Mejores Prácticas Implementadas

1. **Clean Architecture**
   - Separación clara de responsabilidades
   - Código mantenible y testeable
   - Dependencias unidireccionales

2. **Gestión de Estado**
   - BLoC pattern
   - Estados inmutables
   - Manejo de errores consistente

3. **Código Nativo**
   - Integración con Pigeon
   - Código Kotlin optimizado
   - Uso de APIs nativas modernas

4. **Testing**
   - Pruebas unitarias extensivas
   - Mocking de dependencias
   - Cobertura de código significativa

## 📝 Notas de Implementación

### Autenticación Biométrica
- Uso de BiometricPrompt para autenticación nativa
- Fallback automático a PIN
- Manejo de diferentes tipos de biometría

### Escaneo QR
- Implementación optimizada con CameraX
- Procesamiento en tiempo real
- Almacenamiento eficiente en SQLite

### UI/UX
- Diseño adaptativo
- Soporte para temas
- Animaciones optimizadas
- Feedback táctil y visual

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push al Branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- **Sebastian Balvin Mendoza** - *v1.0* - [baalcoder](https://github.com/baalcoder)

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- La comunidad de Flutter por su apoyo
