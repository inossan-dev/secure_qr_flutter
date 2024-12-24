import 'models.dart';

/// Extension QRValidationResultExtension
///
/// Cette extension enrichit la classe QRValidationResult avec des méthodes utilitaires
/// qui facilitent l'exploitation des résultats de validation. Elle permet notamment
/// de présenter les résultats de manière conviviale aux utilisateurs et d'accéder
/// aux données de façon typée et sécurisée.
extension QRValidationResultExtension on QRValidationResult {
  /// Convertit le résultat de validation en un message compréhensible par l'utilisateur.
  ///
  /// Cette méthode fournit des messages adaptés aux différents états possibles :
  /// - Pour un QR code valide : message de succès
  /// - Pour un QR code expiré : indication de l'expiration
  /// - Pour un QR code invalide : détail de l'erreur ou message générique
  ///
  /// Returns : Un message clair et compréhensible pour l'utilisateur final
  String get userMessage {
    if (isValid) {
      return 'QR code valide';
    } else if (isExpired) {
      return 'QR code expiré';
    } else {
      return error ?? 'QR code invalide';
    }
  }

  /// Vérifie la présence d'une donnée spécifique dans le résultat.
  ///
  /// Cette méthode combine la vérification de validité et la présence
  /// d'une clé donnée, simplifiant ainsi les conditions dans le code.
  ///
  /// [key] : La clé de la donnée recherchée
  ///
  /// Returns : true si le résultat est valide et contient la clé spécifiée
  bool hasData(String key) {
    return isValid && data?.containsKey(key) == true;
  }

  /// Récupère une donnée typée avec gestion de valeur par défaut.
  ///
  /// Cette méthode offre une façon sûre et typée d'accéder aux données,
  /// en gérant automatiquement les cas d'erreur et les conversions de type.
  ///
  /// Exemple d'utilisation :
  /// ```dart
  /// final age = result.getData<int>('age', defaultValue: 0);
  /// final name = result.getData<String>('name', defaultValue: 'Inconnu');
  /// ```
  ///
  /// [T] : Le type de donnée attendu
  /// [key] : La clé de la donnée
  /// [defaultValue] : Valeur retournée en cas d'absence ou d'erreur
  ///
  /// Returns : La valeur typée ou la valeur par défaut
  T? getData<T>(String key, {T? defaultValue}) {
    if (!isValid) return defaultValue;
    final value = data?[key];
    if (value is T) return value;
    return defaultValue;
  }
}

/// CustomQRValidator
///
/// Cette classe permet de définir et d'appliquer des règles de validation
/// personnalisées aux QR codes. Elle est particulièrement utile pour
/// implémenter des validations métier spécifiques au-delà des vérifications
/// cryptographiques de base.
class CustomQRValidator {
  /// Liste des règles de validation à appliquer
  final List<ValidationRule> rules;

  /// Crée un validateur avec un ensemble de règles spécifiques
  CustomQRValidator(this.rules);

  /// Applique toutes les règles de validation au résultat.
  ///
  /// Cette méthode vérifie d'abord la validité technique du QR code,
  /// puis applique séquentiellement chaque règle métier définie.
  ///
  /// [baseResult] : Le résultat initial de la validation technique
  ///
  /// Returns : Le résultat final après application de toutes les règles
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

/// Type de fonction définissant une règle de validation
///
/// Une règle prend en entrée les données du QR code et retourne :
/// - null si la validation réussit
/// - un message d'erreur en cas d'échec
typedef ValidationRule = String? Function(Map<String, dynamic> data);

/// Collection de règles de validation couramment utilisées
///
/// Cette classe fournit des règles de validation réutilisables pour
/// les cas d'usage les plus fréquents. Elle peut être étendue avec
/// d'autres règles selon les besoins spécifiques de l'application.
class CommonValidationRules {
  /// Crée une règle vérifiant la présence d'un champ obligatoire.
  ///
  /// [fieldName] : Le nom du champ à vérifier
  ///
  /// Returns : Une règle de validation pour ce champ
  static ValidationRule requiredField(String fieldName) {
    return (data) {
      if (!data.containsKey(fieldName) || data[fieldName] == null) {
        return 'Le champ $fieldName est requis';
      }
      return null;
    };
  }

  /// Crée une règle vérifiant qu'un champ numérique est dans une plage donnée.
  ///
  /// [fieldName] : Le nom du champ à vérifier
  /// [min] : La valeur minimum autorisée
  /// [max] : La valeur maximum autorisée
  ///
  /// Returns : Une règle de validation pour ce champ
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