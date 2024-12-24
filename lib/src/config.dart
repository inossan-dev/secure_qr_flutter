/// SecureQRConfig
///
/// Configuration pour la génération et la validation de QR codes sécurisés.
/// Cette classe regroupe tous les paramètres de sécurité nécessaires pour
/// créer et valider des QR codes avec différents niveaux de protection.
///
/// La classe propose deux mécanismes principaux de sécurité :
/// 1. Le chiffrement du contenu (protège la confidentialité)
/// 2. La signature numérique (garantit l'authenticité)
///
/// Elle intègre également une gestion de la durée de validité des QR codes,
/// permettant de créer des QR codes à durée limitée (par exemple pour des
/// tickets ou des badges temporaires).
///
/// Exemple d'utilisation :
/// ```dart
/// final config = SecureQRConfig(
///   secretKey: "votre_clé_secrète_d'au_moins_32_caractères",
///   validityDuration: Duration(hours: 1),
///   enableEncryption: true,
///   enableSignature: true,
/// );
/// ```
class SecureQRConfig {
  /// Clé secrète utilisée pour le chiffrement et la signature.
  ///
  /// Cette clé doit :
  /// - Faire au moins 32 caractères si le chiffrement est activé
  /// - Rester confidentielle et être stockée de manière sécurisée
  /// - Être identique sur tous les appareils devant valider les QR codes
  final String secretKey;

  /// Durée de validité des QR codes générés.
  ///
  /// Par défaut : 5 minutes
  ///
  /// Cette durée détermine pendant combien de temps un QR code reste valide
  /// après sa génération. Une fois cette durée écoulée, le QR code sera
  /// considéré comme expiré lors de la validation.
  ///
  /// Particulièrement utile pour :
  /// - Les tickets d'événements
  /// - Les badges d'accès temporaires
  /// - Les jetons d'authentification
  final Duration validityDuration;

  /// Active ou désactive le chiffrement du contenu du QR code.
  ///
  /// Par défaut : true
  ///
  /// Quand activé :
  /// - Le contenu du QR code est chiffré avec la clé secrète
  /// - Seuls les appareils possédant la clé peuvent lire le contenu
  /// - La clé secrète doit faire au moins 32 caractères
  ///
  /// À désactiver si :
  /// - Le contenu n'a pas besoin d'être confidentiel
  /// - La performance est prioritaire sur la sécurité
  final bool enableEncryption;

  /// Active ou désactive la signature numérique du QR code.
  ///
  /// Par défaut : true
  ///
  /// Quand activé :
  /// - Une signature est calculée à partir du contenu et de la clé secrète
  /// - Permet de vérifier que le QR code n'a pas été modifié
  /// - Garantit que le QR code a été généré par une source autorisée
  ///
  /// À désactiver si :
  /// - L'authenticité du QR code n'est pas critique
  /// - La performance est prioritaire sur la sécurité
  final bool enableSignature;

  /// Crée une nouvelle configuration pour les QR codes sécurisés.
  ///
  /// [secretKey] est requis et doit faire au moins 32 caractères si
  /// [enableEncryption] est true.
  ///
  /// Throws :
  /// - [ArgumentError] si la clé est trop courte quand le chiffrement est activé
  SecureQRConfig({
    required this.secretKey,
    this.validityDuration = const Duration(minutes: 5),
    this.enableEncryption = true,
    this.enableSignature = true,
  }) {
    if (enableEncryption && secretKey.length < 32) {
      throw ArgumentError('La clé secrète doit faire au moins 32 caractères quand le chiffrement est activé');
    }
  }
}