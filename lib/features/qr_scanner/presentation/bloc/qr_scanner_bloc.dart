import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_auth_app/core/database/database_helper.dart';
import 'package:qr_auth_app/core/pigeon/auth_qr_api.g.dart';
import 'package:qr_auth_app/features/qr_scanner/domain/models/qr_code.dart';

// Events
abstract class QRScannerEvent {}

class StartScanning extends QRScannerEvent {}

class StopScanning extends QRScannerEvent {}

class QRCodeDetected extends QRScannerEvent {
  final String data;
  QRCodeDetected(this.data);
}

class LoadQRCodes extends QRScannerEvent {}

class DeleteQRCode extends QRScannerEvent {
  final int id;
  DeleteQRCode(this.id);
}

// States
abstract class QRScannerState {}

class QRScannerInitial extends QRScannerState {}

class QRScannerStarted extends QRScannerState {
  final List<QRCode> codes;
  QRScannerStarted({this.codes = const []});
}

class QRScannerStopped extends QRScannerState {
  final List<QRCode> codes;
  QRScannerStopped({this.codes = const []});
}

class QRCodeFound extends QRScannerState {
  final String data;
  final List<QRCode> codes;
  QRCodeFound(this.data, {this.codes = const []});
}

class QRScannerError extends QRScannerState {
  final String error;
  final List<QRCode> codes;
  QRScannerError(this.error, {this.codes = const []});
}

class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> {
  final QRScannerApi _qrScannerApi;
  final DatabaseHelper _databaseHelper;
  List<QRCode> _scannedCodes = [];

  QRScannerBloc(this._qrScannerApi)
      : _databaseHelper = DatabaseHelper.instance,
        super(QRScannerInitial()) {
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<QRCodeDetected>(_onQRCodeDetected);
    on<LoadQRCodes>(_onLoadQRCodes);
    on<DeleteQRCode>(_onDeleteQRCode);

    // Cargar códigos al iniciar
    add(LoadQRCodes());
  }

  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _qrScannerApi.startScanner();
      emit(QRScannerStarted(codes: _scannedCodes));
    } catch (e) {
      emit(QRScannerError(e.toString(), codes: _scannedCodes));
    }
  }

  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _qrScannerApi.stopScanner();
      emit(QRScannerStopped(codes: _scannedCodes));
    } catch (e) {
      emit(QRScannerError(e.toString(), codes: _scannedCodes));
    }
  }

  Future<void> _onQRCodeDetected(
    QRCodeDetected event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      // Guardar en la base de datos
      await _databaseHelper.insertQRCode(event.data);
      
      // Recargar la lista
      await _loadCodes();
      
      emit(QRCodeFound(event.data, codes: _scannedCodes));
    } catch (e) {
      emit(QRScannerError('Error al guardar el código QR: ${e.toString()}',
          codes: _scannedCodes));
    }
  }

  Future<void> _onLoadQRCodes(
    LoadQRCodes event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _loadCodes();
      emit(QRScannerStarted(codes: _scannedCodes));
    } catch (e) {
      emit(QRScannerError('Error al cargar códigos QR: ${e.toString()}',
          codes: _scannedCodes));
    }
  }

  Future<void> _onDeleteQRCode(
    DeleteQRCode event,
    Emitter<QRScannerState> emit,
  ) async {
    try {
      await _databaseHelper.deleteQRCode(event.id);
      await _loadCodes();
      emit(QRScannerStarted(codes: _scannedCodes));
    } catch (e) {
      emit(QRScannerError('Error al eliminar el código QR: ${e.toString()}',
          codes: _scannedCodes));
    }
  }

  Future<void> _loadCodes() async {
    final maps = await _databaseHelper.getQRCodes();
    _scannedCodes = maps.map((map) => QRCode.fromMap(map)).toList();
  }

  @override
  Future<void> close() {
    _qrScannerApi.stopScanner();
    return super.close();
  }
}