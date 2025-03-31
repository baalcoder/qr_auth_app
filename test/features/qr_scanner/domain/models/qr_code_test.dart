import 'package:flutter_test/flutter_test.dart';
import 'package:qr_auth_app/features/qr_scanner/domain/models/qr_code.dart';

void main() {
  group('QRCode', () {
    test('should create QRCode instance from map', () {
      // Arrange
      final timestamp = DateTime.now();
      final map = {
        'id': 1,
        'data': 'https://example.com',
        'timestamp': timestamp.toIso8601String(),
      };

      // Act
      final qrCode = QRCode.fromMap(map);

      // Assert
      expect(qrCode.id, equals(1));
      expect(qrCode.data, equals('https://example.com'));
      expect(qrCode.timestamp.toIso8601String(), equals(timestamp.toIso8601String()));
    });

    test('should convert QRCode instance to map', () {
      // Arrange
      final timestamp = DateTime.now();
      final qrCode = QRCode(
        id: 1,
        data: 'https://example.com',
        timestamp: timestamp,
      );

      // Act
      final map = qrCode.toMap();

      // Assert
      expect(map['id'], equals(1));
      expect(map['data'], equals('https://example.com'));
      expect(map['timestamp'], equals(timestamp.toIso8601String()));
    });

    test('should handle null id when creating from map', () {
      // Arrange
      final timestamp = DateTime.now();
      final map = {
        'data': 'https://example.com',
        'timestamp': timestamp.toIso8601String(),
      };

      // Act
      final qrCode = QRCode.fromMap(map);

      // Assert
      expect(qrCode.id, isNull);
      expect(qrCode.data, equals('https://example.com'));
      expect(qrCode.timestamp.toIso8601String(), equals(timestamp.toIso8601String()));
    });

    test('should handle null id when converting to map', () {
      // Arrange
      final timestamp = DateTime.now();
      final qrCode = QRCode(
        data: 'https://example.com',
        timestamp: timestamp,
      );

      // Act
      final map = qrCode.toMap();

      // Assert
      expect(map['id'], isNull);
      expect(map['data'], equals('https://example.com'));
      expect(map['timestamp'], equals(timestamp.toIso8601String()));
    });
  });
}