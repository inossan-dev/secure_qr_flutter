import 'package:secure_qr_flutter/secure_qr_flutter.dart';

class TestData {
  static const String validKey = '2024#@#qrcod#orange@##perform#==';
  static const String shortKey = 'court';

  static final Map<String, dynamic> sampleData = {
    'id': '123',
    'name': 'test',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  static final SecureQRConfig defaultConfig = SecureQRConfig(
    secretKey: validKey,
    validityDuration: const Duration(minutes: 5),
    enableEncryption: true,
    enableSignature: true,
  );

  static final SecureQRConfig testConfig = SecureQRConfig(
    secretKey: shortKey,
    enableEncryption: false,
    validityDuration: const Duration(seconds: 10),
  );
}