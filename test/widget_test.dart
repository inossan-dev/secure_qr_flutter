import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';
import 'package:secure_qr_flutter/src/auto_regenerating_qr_widget.dart';
import 'package:secure_qr_flutter/src/validity_indicator_qr_widget.dart';
import 'helpers/test_data.dart';

void main() {
  group('AutoRegeneratingQR Tests', () {
    testWidgets('régénération automatique', (WidgetTester tester) async {
      final generator = SecureQRGenerator(TestData.defaultConfig);
      String? lastGeneratedData;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AutoRegeneratingQRWidget(
            data: TestData.sampleData,
            generator: generator,
            regenerationInterval: const Duration(seconds: 1),
            builder: (data) {
              lastGeneratedData = data;
              return Text(data);
            },
          ),
        ),
      ));

      final initialData = lastGeneratedData;
      await tester.pump(const Duration(seconds: 2));

      expect(lastGeneratedData, isNot(equals(initialData)));
    });

    testWidgets('ValidityIndicatorQR affichage', (WidgetTester tester) async {
      final generator = SecureQRGenerator(TestData.defaultConfig);
      final qrData = generator.generateQRPayload(TestData.sampleData);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ValidityIndicatorQRWidget(
            qrData: qrData,
            generator: generator,
            qrBuilder: (data) => Text('QR: $data'),
            validityBuilder: (result) => Text(
                result.isValid ? 'Valide' : 'Invalide'
            ),
          ),
        ),
      ));

      expect(find.text('Valide'), findsOneWidget);
      expect(find.textContaining('QR:'), findsOneWidget);
    });
  });
}