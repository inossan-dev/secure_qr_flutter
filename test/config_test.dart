import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';
import 'helpers/test_data.dart';

void main() {
  group('SecureQRConfig Tests', () {
    test('configuration valide avec chiffrement', () {
      final config = SecureQRConfig(
        secretKey: TestData.validKey,
        enableEncryption: true,
      );

      expect(config.enableEncryption, true);
      expect(config.secretKey, TestData.validKey);
      expect(config.validityDuration, isA<Duration>());
    });

    test('configuration sans chiffrement', () {
      final config = SecureQRConfig(
        secretKey: TestData.shortKey,
        enableEncryption: false,
      );

      expect(config.enableEncryption, false);
      expect(config.enableSignature, true);
    });

    test('rejet de clé invalide avec chiffrement', () {
      expect(() => SecureQRConfig(
        secretKey: TestData.shortKey,
        enableEncryption: true,
      ), throwsArgumentError);
    });

    test('configuration avec durée personnalisée', () {
      final config = SecureQRConfig(
        secretKey: TestData.validKey,
        validityDuration: const Duration(minutes: 30),
      );

      expect(config.validityDuration, const Duration(minutes: 30));
    });
  });
}