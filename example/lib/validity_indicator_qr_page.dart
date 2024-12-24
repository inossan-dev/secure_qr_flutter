import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';

class ValidityIndicatorQrPage extends StatefulWidget {
  const ValidityIndicatorQrPage({super.key});

  @override
  State<ValidityIndicatorQrPage> createState() => _ValidityIndicatorQrPageState();
}

class _ValidityIndicatorQrPageState extends State<ValidityIndicatorQrPage> {
  // 1. Configuration basique
  final config = SecureQRConfig(
    secretKey: '2024#@#qrcod#orange@##perform#==',
    enableEncryption: false,  // Activer/désactiver le chiffrement
    validityDuration: const Duration(seconds: 10),
  );

// 2. Création du générateur
  late SecureQRGenerator generator;

// 3. Générer un QR code simple
  String generateSimpleQR() {
    return generator.generateQRPayload({
      'userId': '123',
      'timestamp': DateTime.now().toString()
    });
  }

  @override
  void initState() {
    generator = SecureQRGenerator(config);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Etat Qrcode'),
      ),
      body: Center(
        child: ValidityIndicatorQRWidget(
          //Invalid QRcode for example: //'eyJkYXRhIjp7InVzZXJJZCI6IjEyMyJ9LCJ0aW1lc3RhbXAiOjE3MzUwNTQ1NTM0MDUsImlkIjoiNTY0YTY4YWUtZDk1Ny00NmRjLThiY2UtNmVjYjZkMTdmNDI0IiwidmVyc2lvbiI6MSwic2lnbmF0dXJlIjoiODliMzNlZDFkY2UzNGM0YWYxNjU2ZTA3ZGMwNGQ4MzM0YjI4ZGE4OTM1NzYzYWI1NjQxMzUyODI0YzQxZDE5YiJ9',
          //qrData: 'eyJkYXRhIjp7InVzZXJJZCI6IjEyMyJ9LCJ0aW1lc3RhbXAiOjE3MzUwNTQ1NTM0MDUsImlkIjoiNTY0YTY4YWUtZDk1Ny00NmRjLThiY2UtNmVjYjZkMTdmNDI0IiwidmVyc2lvbiI6MSwic2lnbmF0dXJlIjoiODliMzNlZDFkY2UzNGM0YWYxNjU2ZTA3ZGMwNGQ4MzM0YjI4ZGE4OTM1NzYzYWI1NjQxMzUyODI0YzQxZDE5YiJ9',
          qrData: generateSimpleQR(),
          generator: generator,
          qrBuilder: (qrData) => QrImageView(
            data: qrData,
            size: 200,
          ),
          validityBuilder: (QRValidationResult result) {
            return Text(result.userMessage);
          },
        ),
      ),
    );
  }
}
