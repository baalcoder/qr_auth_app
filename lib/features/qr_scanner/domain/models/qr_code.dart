class QRCode {
  final int? id;
  final String data;
  final DateTime timestamp;

  QRCode({
    this.id,
    required this.data,
    required this.timestamp,
  });

  factory QRCode.fromMap(Map<String, dynamic> map) {
    return QRCode(
      id: map['id'] as int?,
      data: map['data'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}