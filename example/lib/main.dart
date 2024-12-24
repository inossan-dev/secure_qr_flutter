import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';

// 1. Configuration basique
final config = SecureQRConfig(
  secretKey: '2024#@#qrcod#orange@##perform#==',
  enableEncryption: false,  // Activer/désactiver le chiffrement
  validityDuration: const Duration(seconds: 10),
);

// 2. Création du générateur
final generator = SecureQRGenerator(config);

// 3. Générer un QR code simple
String generateSimpleQR() {
 return generator.generateQRPayload({
    'userId': '123',
    'timestamp': DateTime.now().toString()
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AutoRegeneratingQR Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: AutoRegeneratingQRWidget(
          data: const {'userId': '123'},
          generator: generator,
          regenerationInterval: const Duration(seconds: 10),
          builder: (qrData) => QrImageView(
            data: qrData,
            size: 200,
          ),
        ),
      ),
    );
  }
}
