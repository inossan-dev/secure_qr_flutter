import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:uuid/uuid.dart';
import 'config.dart';
import 'models.dart';

/// Générateur de QR codes sécurisés
/// Cette classe gère la génération et la validation des QR codes
/// en utilisant le chiffrement et la signature selon la configuration fournie
class SecureQRGenerator {
  final SecureQRConfig config;
  final Encrypter? _encrypter;
  final IV? _iv;

  /// Constructeur qui initialise l'encrypteur si le chiffrement est activé
  SecureQRGenerator(this.config) :
        _encrypter = config.enableEncryption ?
        Encrypter(AES(Key.fromUtf8(config.secretKey.padRight(32)))) : null,
        _iv = config.enableEncryption ? IV.fromLength(16) : null;

  /// Génère un payload QR code à partir des données fournies
  /// [data] : Les données à encoder dans le QR code
  String generateQRPayload(Map<String, dynamic> data) {
    // Création du payload de base avec un identifiant unique
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v4();

    final payload = {
      'data': data,
      'timestamp': timestamp,
      'id': uuid,
      'version': 1, // Utile pour les migrations futures
    };

    // Ajout de la signature si activée
    if (config.enableSignature) {
      payload['signature'] = _generateSignature(Map.from(payload));
    }

    final jsonPayload = jsonEncode(payload);

    // Application du chiffrement si activé
    if (config.enableEncryption && _encrypter != null && _iv != null) {
      try {
        final encrypted = _encrypter!.encrypt(jsonPayload, iv: _iv!);
        return base64Encode(encrypted.bytes);
      } catch (e) {
        throw QRGenerationException('Erreur de chiffrement: ${e.toString()}');
      }
    } else {
      // Simple encodage en base64 si pas de chiffrement
      return base64Encode(utf8.encode(jsonPayload));
    }
  }

  /// Valide un payload QR code et retourne les données s'il est valide
  /// [encodedPayload] : Le contenu du QR code à valider
  QRValidationResult validateQRPayload(String encodedPayload) {
    try {
      // Décodage du payload
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

      // Parse du JSON
      late Map<String, dynamic> payload;
      try {
        payload = jsonDecode(jsonPayload);
      } catch (e) {
        return QRValidationResult.invalid("JSON invalide");
      }

      // Vérification de la version
      if (payload['version'] != 1) {
        return QRValidationResult.invalid("Version non supportée");
      }

      // Vérification de la signature si activée
      if (config.enableSignature) {
        final originalSignature = payload.remove('signature');
        final calculatedSignature = _generateSignature(payload);

        if (originalSignature != calculatedSignature) {
          return QRValidationResult.invalid("Signature invalide");
        }
      }

      // Vérification de la validité temporelle
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

  /// Génère une signature HMAC pour le payload
  String _generateSignature(Map<String, dynamic> payload) {
    final data = jsonEncode(payload);
    final key = utf8.encode(config.secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}

/// Exception personnalisée pour les erreurs de génération de QR code
class QRGenerationException implements Exception {
  final String message;
  QRGenerationException(this.message);

  @override
  String toString() => 'QRGenerationException: $message';
}