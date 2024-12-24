import 'package:flutter/material.dart';
import 'package:secure_qr_flutter/src/generator.dart';
import 'package:secure_qr_flutter/src/models.dart';

/// ValidityIndicatorQRWidget
/// 
/// Un widget Flutter qui combine l'affichage d'un QR code avec un indicateur
/// de validité optionnel. Ce widget est particulièrement utile pour les cas
/// d'utilisation où l'on doit non seulement afficher un QR code, mais aussi
/// indiquer visuellement si son contenu est valide selon certains critères.
///
/// Fonctionnalités principales :
/// - Affichage personnalisable du QR code
/// - Validation du contenu du QR code via un générateur sécurisé
/// - Indicateur de validité optionnel et personnalisable
/// 
/// Exemple d'utilisation :
/// ```dart
/// ValidityIndicatorQRWidget(
///   qrData: "https://example.com",
///   generator: SecureQRGenerator(),
///   qrBuilder: (data) => QrImage(data: data),
///   validityBuilder: (result) => Text(result.isValid ? "Valide" : "Invalid"),
/// )
/// ```
class ValidityIndicatorQRWidget extends StatelessWidget {
  /// Les données à encoder dans le QR code.
  /// Peut être n'importe quelle chaîne de caractères valide pour un QR code.
  final String qrData;

  /// Le générateur sécurisé utilisé pour valider le contenu du QR code.
  /// Doit implémenter la logique de validation spécifique à l'application.
  final SecureQRGenerator generator;

  /// Fonction de construction du QR code.
  /// Permet une personnalisation complète de l'apparence du QR code.
  /// 
  /// Paramètres :
  /// - qrData : Les données à encoder dans le QR code
  /// 
  /// Retourne un Widget qui représente le QR code
  final Widget Function(String qrData) qrBuilder;

  /// Fonction optionnelle de construction de l'indicateur de validité.
  /// Si null, aucun indicateur ne sera affiché.
  /// 
  /// Paramètres :
  /// - result : Le résultat de la validation du QR code
  /// 
  /// Retourne un Widget qui représente l'indicateur de validité
  final Widget Function(QRValidationResult result)? validityBuilder;

  /// Constructeur du widget.
  /// 
  /// Paramètres obligatoires :
  /// - qrData : Les données du QR code
  /// - generator : Le générateur sécurisé pour la validation
  /// - qrBuilder : Le constructeur du QR code
  /// 
  /// Paramètre optionnel :
  /// - validityBuilder : Le constructeur de l'indicateur de validité
  const ValidityIndicatorQRWidget({
    super.key,
    required this.qrData,
    required this.generator,
    required this.qrBuilder,
    this.validityBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Validation du contenu du QR code
    final result = generator.validateQRPayload(qrData);

    // Construction de la colonne verticale contenant le QR code
    // et optionnellement l'indicateur de validité
    return Column(
      mainAxisSize: MainAxisSize.min,  // La colonne prend la taille minimum nécessaire
      children: [
        qrBuilder(qrData),  // Construction du QR code
        // Ajout conditionnel de l'indicateur de validité
        if (validityBuilder != null) validityBuilder!(result),
      ],
    );
  }
}