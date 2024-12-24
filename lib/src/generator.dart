import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:uuid/uuid.dart';
import 'config.dart';
import 'models.dart';

/// SecureQRGenerator
///
/// Cette classe implémente un système complet de génération et validation de QR codes
/// sécurisés. Elle utilise plusieurs niveaux de protection pour garantir l'authenticité,
/// l'intégrité et la confidentialité des données encodées dans les QR codes.
///
/// Caractéristiques de sécurité :
/// 1. Chiffrement AES pour la confidentialité des données
/// 2. Signature HMAC-SHA256 pour l'intégrité et l'authenticité
/// 3. Horodatage pour la gestion de la durée de validité
/// 4. Identifiants uniques (UUID) pour le traçage
///
/// Exemple d'utilisation :
/// ```dart
/// final generator = SecureQRGenerator(SecureQRConfig(
///   secretKey: "votre_clé_secrète_très_longue",
///   validityDuration: Duration(hours: 1),
/// ));
///
/// // Génération
/// final qrData = generator.generateQRPayload({
///   "userId": "123",
///   "accessLevel": "VIP"
/// });
///
/// // Validation
/// final result = generator.validateQRPayload(qrData);
/// if (result.isValid) {
///   print("Données valides: ${result.data}");
/// }
/// ```
class SecureQRGenerator {
  /// Configuration utilisée pour la génération et validation des QR codes
  final SecureQRConfig config;

  /// Instance de l'encrypteur AES, null si le chiffrement est désactivé
  final Encrypter? _encrypter;

  /// Vecteur d'initialisation pour le chiffrement AES
  final IV? _iv;

  /// Crée un nouveau générateur de QR codes sécurisés avec la configuration spécifiée.
  ///
  /// Initialise automatiquement le système de chiffrement si celui-ci est activé
  /// dans la configuration. Le chiffrement utilise l'algorithme AES avec la clé
  /// fournie dans la configuration (complétée à 32 caractères si nécessaire).
  SecureQRGenerator(this.config) :
        _encrypter = config.enableEncryption ?
        Encrypter(AES(Key.fromUtf8(config.secretKey.padRight(32)))) : null,
        _iv = config.enableEncryption ? IV.fromLength(16) : null;

  /// Génère un payload sécurisé pour un QR code à partir des données fournies.
  ///
  /// Cette méthode effectue les opérations suivantes :
  /// 1. Ajoute un timestamp et un UUID aux données
  /// 2. Ajoute une version pour la compatibilité future
  /// 3. Calcule une signature si activée
  /// 4. Chiffre l'ensemble si activé
  /// 5. Encode le résultat en base64
  ///
  /// [data] : Map contenant les données à encoder dans le QR code
  ///
  /// Throws :
  /// - [QRGenerationException] en cas d'erreur pendant la génération
  String generateQRPayload(Map<String, dynamic> data) {
    // Structure du payload avec les métadonnées
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v4();

    final payload = {
      'data': data,            // Données utilisateur
      'timestamp': timestamp,  // Pour la validation temporelle
      'id': uuid,             // Identifiant unique
      'version': 1,           // Version du format
    };

    // Ajout de la signature HMAC si activée
    if (config.enableSignature) {
      payload['signature'] = _generateSignature(Map.from(payload));
    }

    final jsonPayload = jsonEncode(payload);

    // Application du chiffrement AES si activé
    if (config.enableEncryption && _encrypter != null && _iv != null) {
      try {
        final encrypted = _encrypter!.encrypt(jsonPayload, iv: _iv!);
        return base64Encode(encrypted.bytes);
      } catch (e) {
        throw QRGenerationException('Erreur de chiffrement: ${e.toString()}');
      }
    }

    // Si pas de chiffrement, simple encodage base64
    return base64Encode(utf8.encode(jsonPayload));
  }

  /// Valide un payload de QR code et extrait les données s'il est valide.
  ///
  /// Cette méthode effectue les vérifications suivantes :
  /// 1. Déchiffrement ou décodage base64
  /// 2. Parsing du JSON
  /// 3. Vérification de la version
  /// 4. Validation de la signature si activée
  /// 5. Vérification de la durée de validité
  ///
  /// [encodedPayload] : Contenu du QR code à valider
  ///
  /// Returns :
  /// - [QRValidationResult] contenant le statut de validation et les données
  QRValidationResult validateQRPayload(String encodedPayload) {
    try {
      // Étape 1 : Déchiffrement ou décodage
      String jsonPayload;
      if (config.enableEncryption && _encrypter != null && _iv != null) {
        try {
          final encrypted = Encrypted(base64Decode(encodedPayload));
          jsonPayload = _encrypter!.decrypt(encrypted, iv: _iv!);
        } catch (e) {
          return QRValidationResult.invalid("Erreur de déchiffrement");
        }
      } else {
        try {
          jsonPayload = utf8.decode(base64Decode(encodedPayload));
        } catch (e) {
          return QRValidationResult.invalid("Erreur de décodage base64");
        }
      }

      // Étapes 2-5 : Validation complète
      late Map<String, dynamic> payload;
      try {
        payload = jsonDecode(jsonPayload);
      } catch (e) {
        return QRValidationResult.invalid("JSON invalide");
      }

      // Vérification de compatibilité
      if (payload['version'] != 1) {
        return QRValidationResult.invalid("Version non supportée");
      }

      // Validation de la signature
      if (config.enableSignature) {
        final originalSignature = payload.remove('signature');
        final calculatedSignature = _generateSignature(payload);

        if (originalSignature != calculatedSignature) {
          return QRValidationResult.invalid("Signature invalide");
        }
      }

      // Vérification de l'expiration
      final timestamp = payload['timestamp'];
      final generationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(generationTime) > config.validityDuration) {
        return QRValidationResult.expired();
      }

      return QRValidationResult.valid(payload['data']);

    } catch (e) {
      return QRValidationResult.invalid("Erreur inattendue: ${e.toString()}");
    }
  }

  /// Génère une signature HMAC-SHA256 pour un payload donné.
  ///
  /// Cette méthode utilise la clé secrète de la configuration pour générer
  /// une signature cryptographique qui permet de vérifier l'intégrité et
  /// l'authenticité des données.
  ///
  /// [payload] : Données à signer
  ///
  /// Returns : Signature sous forme de chaîne hexadécimale
  String _generateSignature(Map<String, dynamic> payload) {
    final data = jsonEncode(payload);
    final key = utf8.encode(config.secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}

/// Exception spécifique aux erreurs de génération de QR codes
///
/// Cette classe permet de distinguer les erreurs liées à la génération
/// des QR codes des autres types d'erreurs dans l'application.
class QRGenerationException implements Exception {
  final String message;
  QRGenerationException(this.message);

  @override
  String toString() => 'QRGenerationException: $message';
}