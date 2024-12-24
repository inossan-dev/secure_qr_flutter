import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_qr_flutter/secure_qr_flutter.dart';

/// AutoRegeneratingQRWidget est un widget Flutter qui gère automatiquement la génération
/// et la régénération périodique de codes QR sécurisés.
///
/// Ce widget offre deux modes de fonctionnement :
/// 1. Mode par défaut utilisant QrImageView de qr_flutter
/// 2. Mode personnalisé via un builder fourni par l'utilisateur
///
/// Exemple d'utilisation basique :
/// ```dart
/// AutoRegeneratingQRWidget(
///   data: {'userId': '123'},
///   generator: generator,
///   size: 250.0,
/// )
/// ```
///
/// Exemple avec personnalisation complète :
/// ```dart
/// AutoRegeneratingQRWidget(
///   data: {'userId': '123'},
///   generator: generator,
///   regenerationInterval: Duration(minutes: 2),
///   builder: (qrData) => CustomQRWidget(data: qrData),
///   onRegenerate: (newData) => print('Nouveau QR généré'),
///   eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square),
///   dataModuleStyle: QrDataModuleStyle(
///     dataModuleShape: QrDataModuleShape.circle,
///   ),
/// )
/// ```
class AutoRegeneratingQRWidget extends StatefulWidget {
  /// Les données à encoder dans le QR code.
  /// Peut contenir n'importe quel type de données sérialisable en JSON.
  final Map<String, dynamic> data;

  /// Le générateur de QR code à utiliser pour le chiffrement et la sécurisation
  /// des données.
  final SecureQRGenerator generator;

  /// L'intervalle entre chaque régénération automatique du QR code.
  /// Par défaut : 4 minutes
  /// Note : Il est recommandé de définir cet intervalle légèrement inférieur
  /// à la durée de validité configurée dans SecureQRConfig pour assurer
  /// une transition fluide.
  final Duration regenerationInterval;

  /// Fonction optionnelle permettant de personnaliser complètement le rendu
  /// du QR code. Si non fournie, le widget utilisera QrImageView par défaut.
  ///
  /// Le paramètre qrData contient les données encodées et sécurisées prêtes
  /// à être affichées.
  final Widget Function(String qrData)? builder;

  /// Callback optionnel appelé à chaque régénération du QR code.
  /// Utile pour la journalisation ou la synchronisation avec d'autres composants.
  final void Function(String qrData)? onRegenerate;

  /// Taille du QR code en pixels lorsque le mode par défaut est utilisé.
  /// Cette propriété est ignorée si un builder personnalisé est fourni.
  /// Par défaut : 200.0
  final double? size;

  /// Style des yeux du QR code (les trois carrés dans les coins).
  /// Cette propriété est ignorée si un builder personnalisé est fourni.
  /// Voir la documentation de qr_flutter pour plus de détails.
  final QrEyeStyle eyeStyle;

  /// Style des modules de données du QR code.
  /// Cette propriété est ignorée si un builder personnalisé est fourni.
  /// Voir la documentation de qr_flutter pour plus de détails.
  final QrDataModuleStyle dataModuleStyle;

  const AutoRegeneratingQRWidget({
    super.key,
    required this.data,
    required this.generator,
    this.regenerationInterval = const Duration(minutes: 4),
    this.builder,
    this.onRegenerate,
    this.size = 200.0,
    this.eyeStyle = const QrEyeStyle(eyeShape: QrEyeShape.square),
    this.dataModuleStyle = const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle),
  });

  @override
  _AutoRegeneratingQRWidgetState createState() => _AutoRegeneratingQRWidgetState();
}

class _AutoRegeneratingQRWidgetState extends State<AutoRegeneratingQRWidget> {
  /// Stocke les données actuelles du QR code
  late String _currentQRData;

  /// Timer utilisé pour la régénération périodique
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Génère le QR initial et démarre le timer
    _generateQR();
    _startTimer();
  }

  @override
  void didUpdateWidget(AutoRegeneratingQRWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Vérifie si des paramètres importants ont changé
    if (oldWidget.regenerationInterval != widget.regenerationInterval) {
      _startTimer(); // Redémarre le timer avec le nouvel intervalle
    }
    if (oldWidget.data != widget.data) {
      _generateQR(); // Régénère le QR si les données ont changé
    }
  }

  /// Génère un nouveau QR code en utilisant le générateur sécurisé
  void _generateQR() {
    try {
      final newQRData = widget.generator.generateQRPayload(widget.data);
      setState(() {
        _currentQRData = newQRData;
      });
      // Notifie le parent si un callback est fourni
      widget.onRegenerate?.call(newQRData);
    } catch (e) {
      debugPrint('Erreur lors de la génération du QR code: $e');
      // On pourrait ici implémenter une gestion d'erreur plus sophistiquée
      // comme afficher un Snackbar ou un message d'erreur
    }
  }

  /// Configure le timer de régénération périodique
  void _startTimer() {
    _timer?.cancel(); // Annule l'ancien timer s'il existe
    final regenerationDuration = widget.regenerationInterval;
    _timer = Timer.periodic(regenerationDuration, (_) {
      _generateQR();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Nettoyage du timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilise le builder personnalisé ou la vue QR par défaut
    return widget.builder?.call(_currentQRData) ??
        QrImageView(
          data: _currentQRData,
          size: widget.size,
          eyeStyle: widget.eyeStyle,
          dataModuleStyle: widget.dataModuleStyle,
        );
  }
}
