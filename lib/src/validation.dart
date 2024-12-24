import 'models.dart';

/// Extension pour ajouter des méthodes utilitaires au QRValidationResult
extension QRValidationResultExtension on QRValidationResult {
  /// Retourne un message convivial décrivant le résultat de la validation
  String get userMessage {
    if (isValid) {
      return 'QR code valide';
    } else if (isExpired) {
      return 'QR code expiré';
    } else {
      return error ?? 'QR code invalide';
    }
  }

  /// Vérifie si le résultat contient une donnée spécifique
  bool hasData(String key) {
    return isValid && data?.containsKey(key) == true;
  }

  /// Récupère une donnée typée avec une valeur par défaut
  T? getData<T>(String key, {T? defaultValue}) {
    if (!isValid) return defaultValue;
    final value = data?[key];
    if (value is T) return value;
    return defaultValue;
  }
}

/// Validateur personnalisé pour des règles métier spécifiques
class CustomQRValidator {
  final List<ValidationRule> rules;

  CustomQRValidator(this.rules);

  /// Valide un résultat selon les règles définies
  QRValidationResult validate(QRValidationResult baseResult) {
    if (!baseResult.isValid) return baseResult;

    for (final rule in rules) {
      final error = rule(baseResult.data!);
      if (error != null) {
        return QRValidationResult.invalid(error);
      }
    }

    return baseResult;
  }
}

/// Type définissant une règle de validation
typedef ValidationRule = String? Function(Map<String, dynamic> data);

/// Règles de validation courantes
class CommonValidationRules {
  /// Vérifie qu'un champ requis est présent
  static ValidationRule requiredField(String fieldName) {
    return (data) {
      if (!data.containsKey(fieldName) || data[fieldName] == null) {
        return 'Le champ $fieldName est requis';
      }
      return null;
    };
  }

  /// Vérifie qu'un champ numérique est dans une plage donnée
  static ValidationRule numberInRange(String fieldName, num min, num max) {
    return (data) {
      final value = data[fieldName];
      if (value is! num) return 'Le champ $fieldName doit être un nombre';
      if (value < min || value > max) {
        return 'Le champ $fieldName doit être entre $min et $max';
      }
      return null;
    };
  }
}