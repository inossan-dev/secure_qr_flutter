import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';

void main() {
  late SecureQRGenerator generator;
  final testData = {'id': '123', 'name': 'test'};

  setUp(() {
    final config = SecureQRConfig(
      secretKey: '2024#@#qrcod#orange@##perform#==',
      validityDuration: const Duration(seconds: 5),
      enableEncryption: true,
    );
    generator = SecureQRGenerator(config);
  });

  test('Génération basique', () {
    final qrData = generator.generateQRPayload(testData);
    expect(qrData, isNotEmpty);
  });

  test('Validation réussie', () {
    final qrData = generator.generateQRPayload(testData);
    final result = generator.validateQRPayload(qrData);
    expect(result.isValid, true);
    expect(result.data?['id'], '123');
  });

  test('Mode sans chiffrement', () {
    final config = SecureQRConfig(
      secretKey: 'court',
      enableEncryption: false,
    );
    final generator = SecureQRGenerator(config);

    final qrData = generator.generateQRPayload(testData);
    final result = generator.validateQRPayload(qrData);
    expect(result.isValid, true);
  });
}