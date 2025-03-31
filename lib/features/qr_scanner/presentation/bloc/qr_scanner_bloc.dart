import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_auth_app/core/pigeon/auth_qr_api.g.dart';

// Events
abstract class QRScannerEvent {}

class StartScanning extends QRScannerEvent {}
class StopScanning extends QRScannerEvent {}
class QRCodeDetected extends QRScannerEvent {
  final String data;
  QRCodeDetected(this.data);
}

// States
abstract class QRScannerState {}

class QRScannerInitial extends QRScannerState {}
class QRScannerStarted extends QRScannerState {}
class QRScannerStopped extends QRScannerState {}
class QRCodeFound extends QRScannerState {
  final String data;
  QRCodeFound(this.data);
}
class QRScannerError extends QRScannerState {
  final String error;
  QRScannerError(this.error);
}

class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> implements QRScannerFlutterApi {
  final QRScannerApi _qrScannerApi;

  QRScannerBloc(this._qrScannerApi) : super(QRScannerInitial()) {
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<QRCodeDetected>(_onQRCodeDetected);

    // Registrar este bloc como el receptor de eventos de QR
    QRScannerFlutterApi.setup(this);
  }

  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _qrScannerApi.startScanner();
      emit(QRScannerStarted());
    } catch (e) {
      emit(QRScannerError(e.toString()));
    }
  }

  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _qrScannerApi.stopScanner();
      emit(QRScannerStopped());
    } catch (e) {
      emit(QRScannerError(e.toString()));
    }
  }

  void _onQRCodeDetected(
    QRCodeDetected event,
    Emitter<QRScannerState> emit,
  ) {
    emit(QRCodeFound(event.data));
  }

  @override
  void onQRCodeDetected(String qrCode) {
    add(QRCodeDetected(qrCode));
  }

  @override
  Future<void> close() async {
    await _qrScannerApi.stopScanner();
    return super.close();
  }
}