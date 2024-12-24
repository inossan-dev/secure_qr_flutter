import 'dart:async';
import 'package:flutter/material.dart';
import 'package:secure_qr_flutter/src/models.dart';
import 'generator.dart';

/// Widget qui régénère automatiquement le QR code à intervalle régulier
class AutoRegeneratingQR extends StatefulWidget {
  /// Les données à encoder dans le QR code
  final Map<String, dynamic> data;

  /// Le générateur de QR code à utiliser
  final SecureQRGenerator generator;

  /// L'intervalle entre chaque régénération
  final Duration regenerationInterval;

  /// Le builder qui construit le widget QR à partir des données encodées
  final Widget Function(String qrData) builder;

  /// Callback appelé à chaque régénération (optionnel)
  final void Function(String qrData)? onRegenerate;

  const AutoRegeneratingQR({
    super.key,
    required this.data,
    required this.generator,
    this.regenerationInterval = const Duration(minutes: 4),
    required this.builder,
    this.onRegenerate,
  });

  @override
  _AutoRegeneratingQRState createState() => _AutoRegeneratingQRState();
}

class _AutoRegeneratingQRState extends State<AutoRegeneratingQR> {
  late String _currentQRData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateQR();
    _startTimer();
  }

  @override
  void didUpdateWidget(AutoRegeneratingQR oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Redémarre le timer si l'intervalle a changé
    if (oldWidget.regenerationInterval != widget.regenerationInterval) {
      _startTimer();
    }
    // Régénère si les données ont changé
    if (oldWidget.data != widget.data) {
      _generateQR();
    }
  }

  void _generateQR() {
    try {
      final newQRData = widget.generator.generateQRPayload(widget.data);
      setState(() {
        _currentQRData = newQRData;
      });
      widget.onRegenerate?.call(newQRData);
    } catch (e) {
      // En cas d'erreur, on pourrait notifier l'utilisateur
      debugPrint('Erreur lors de la génération du QR code: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    // On régénère légèrement avant l'expiration pour assurer la continuité
    final regenerationDuration = widget.regenerationInterval;
    _timer = Timer.periodic(regenerationDuration, (_) {
      _generateQR();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_currentQRData);
}

/// Widget qui affiche un QR code avec un indicateur de validité
class ValidityIndicatorQR extends StatelessWidget {
  final String qrData;
  final SecureQRGenerator generator;
  final Widget Function(String qrData) qrBuilder;
  final Widget Function(QRValidationResult result)? validityBuilder;

  const ValidityIndicatorQR({
    super.key,
    required this.qrData,
    required this.generator,
    required this.qrBuilder,
    this.validityBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final result = generator.validateQRPayload(qrData);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        qrBuilder(qrData),
        if (validityBuilder != null) validityBuilder!(result),
      ],
    );
  }
}