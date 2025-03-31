import 'package:pigeon/pigeon.dart';

// Modelo para la respuesta de autenticación
class AuthResult {
  bool? success;
  String? error;
}

// Modelo para la configuración de autenticación
class AuthConfig {
  String? title;
  String? subtitle;
  String? negativeButtonText;
}

// Modelo para el resultado del escaneo QR
class QRResult {
  String? data;
  String? error;
}

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/pigeon/auth_qr_api.g.dart',
  kotlinOut:
      'android/app/src/main/kotlin/com/example/qr_auth_app/AuthQrApi.kt',
  kotlinOptions: KotlinOptions(package: 'com.example.qr_auth_app'),
))

@HostApi()
abstract class BiometricApi {
  @async
  AuthResult authenticate(AuthConfig config);
  bool isBiometricAvailable();
}

@HostApi()
abstract class QRScannerApi {
  @async
  void startScanner();
  @async
  void stopScanner();
}

@FlutterApi()
abstract class QRScannerFlutterApi {
  void onQRCodeDetected(String qrCode);
}