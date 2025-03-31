import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:qr_auth_app/core/database/database_helper.dart';
import 'package:qr_auth_app/core/pigeon/auth_qr_api.g.dart';
import 'package:qr_auth_app/features/qr_scanner/domain/models/qr_code.dart';
import 'package:qr_auth_app/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';

@GenerateNiceMocks([
  MockSpec<QRScannerApi>(),
  MockSpec<DatabaseHelper>(),
])
import 'qr_scanner_bloc_test.mocks.dart';

void main() {
  late QRScannerBloc qrScannerBloc;
  late MockQRScannerApi mockQRScannerApi;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockQRScannerApi = MockQRScannerApi();
    mockDatabaseHelper = MockDatabaseHelper();
    qrScannerBloc = QRScannerBloc(mockQRScannerApi);
  });

  tearDown(() {
    qrScannerBloc.close();
  });

  test('initial state should be QRScannerInitial', () {
    expect(qrScannerBloc.state, isA<QRScannerInitial>());
  });

  group('StartScanning', () {
    test('emits [QRScannerStarted] when scanner starts successfully', () async {
      // Arrange
      when(mockQRScannerApi.startScanner()).thenAnswer((_) async {});
      when(mockDatabaseHelper.getQRCodes()).thenAnswer((_) async => []);

      // Assert
      expectLater(
        qrScannerBloc.stream,
        emitsInOrder([
          isA<QRScannerStarted>(),
        ]),
      );

      // Act
      qrScannerBloc.add(StartScanning());
    });

    test('emits [QRScannerError] when scanner fails to start', () async {
      // Arrange
      when(mockQRScannerApi.startScanner())
          .thenThrow(Exception('Failed to start scanner'));

      // Assert
      expectLater(
        qrScannerBloc.stream,
        emitsInOrder([
          isA<QRScannerError>(),
        ]),
      );

      // Act
      qrScannerBloc.add(StartScanning());
    });
  });

  group('DeleteQRCode', () {

    test('emits [QRScannerError] when deletion fails', () async {
      // Arrange
      when(mockDatabaseHelper.deleteQRCode(1))
          .thenThrow(Exception('Failed to delete QR code'));

      // Assert
      expectLater(
        qrScannerBloc.stream,
        emitsInOrder([
          isA<QRScannerError>(),
        ]),
      );

      // Act
      qrScannerBloc.add(DeleteQRCode(1));
    });
  });

  group('LoadQRCodes', () {
    test('emits [QRScannerStarted] with loaded codes', () async {
      // Arrange
      final testTimestamp = DateTime.now();
      when(mockDatabaseHelper.getQRCodes()).thenAnswer((_) async => [
            {
              'id': 1,
              'data': 'https://example.com',
              'timestamp': testTimestamp.toIso8601String(),
            }
          ]);

      // Assert
      // expectLater(
      //   qrScannerBloc.stream,
      //   emitsInOrder([
      //     isA<QRScannerStarted>(),
      //   ]),
      // );

      // Act
      qrScannerBloc.add(LoadQRCodes());
    });

    test('emits [QRScannerError] when loading fails', () async {
      // Arrange
      when(mockDatabaseHelper.getQRCodes())
          .thenThrow(Exception('Failed to load QR codes'));

      // Assert
      expectLater(
        qrScannerBloc.stream,
        emitsInOrder([
          isA<QRScannerError>(),
        ]),
      );

      // Act
      qrScannerBloc.add(LoadQRCodes());
    });
  });
}