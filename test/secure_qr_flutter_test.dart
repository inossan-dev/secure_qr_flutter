import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';

void main() {
  group('Configuration Tests', () {
    test('Config avec chiffrement activé', () {
      final config = SecureQRConfig(
        secretKey: '2024#@#qrcod#orange@##perform#==',
        enableEncryption: true,
      );

      expect(config.enableEncryption, true);
      expect(config.secretKey.length, greaterThanOrEqualTo(32));
    });

    test('Config avec chiffrement désactivé', () {
      final config = SecureQRConfig(
        secretKey: 'courte',
        enableEncryption: false,
      );

      expect(config.enableEncryption, false);
    });

    test('Config invalide', () {
      expect(() => SecureQRConfig(
        secretKey: 'trop_courte',
        enableEncryption: true,
      ), throwsArgumentError);
    });
  });

  group('Génération QR Tests', () {
    late SecureQRGenerator generator;
    final testData = {'id': '123', 'name': 'test'};

    setUp(() {
      final config = SecureQRConfig(
        secretKey: '2024#@#qrcod#orange@##perform#==',
        validityDuration: const Duration(seconds: 5),
      );
      generator = SecureQRGenerator(config);
    });

    test('Génération et validation basique', () {
      final qrData = generator.generateQRPayload(testData);
      final result = generator.validateQRPayload(qrData);

      expect(result.isValid, true);
      expect(result.data?['id'], '123');
      expect(result.data?['name'], 'test');
    });

    test('Expiration du QR code', () async {
      final config = SecureQRConfig(
        secretKey: '2024#@#qrcod#orange@##perform#==',
        validityDuration: const Duration(seconds: 1),
      );
      final generator = SecureQRGenerator(config);

      final qrData = generator.generateQRPayload(testData);
      await Future.delayed(const Duration(seconds: 2));

      final result = generator.validateQRPayload(qrData);
      expect(result.isExpired, true);
      expect(result.isValid, false);
    });

    test('Validation avec données corrompues', () {
      final qrData = generator.generateQRPayload(testData);
      final corruptedData = '${qrData.substring(0, qrData.length - 5)}XXXXX';

      final result = generator.validateQRPayload(corruptedData);
      expect(result.isValid, false);
    });
  });

  group('Tests sans chiffrement', () {
    late SecureQRGenerator generator;

    setUp(() {
      final config = SecureQRConfig(
        secretKey: 'courte',
        enableEncryption: false,
        enableSignature: true,
      );
      generator = SecureQRGenerator(config);
    });

    test('Génération sans chiffrement', () {
      final data = {'test': 'data'};
      final qrData = generator.generateQRPayload(data);
      final result = generator.validateQRPayload(qrData);

      expect(result.isValid, true);
      expect(result.data?['test'], 'data');
    });
  });

  group('Tests de Widget', () {
    testWidgets('AutoRegeneratingQR regeneration',
            (WidgetTester tester) async {
          final config = SecureQRConfig(
            secretKey: '2024#@#qrcod#orange@##perform#==',
          );
          final generator = SecureQRGenerator(config);

          await tester.pumpWidget(
            MaterialApp(
              home: AutoRegeneratingQR(
                data: const {'test': 'data'},
                generator: generator,
                regenerationInterval: const Duration(seconds: 1),
                builder: (data) => Text(data),
              ),
            ),
          );

          final initialText = find.byType(Text);
          final initialData = (initialText.evaluate().first.widget as Text).data;

          // Attend la régénération
          await tester.pump(const Duration(seconds: 2));

          final newText = find.byType(Text);
          final newData = (newText.evaluate().first.widget as Text).data;

          expect(initialData, isNot(equals(newData)));
        });
  });
}