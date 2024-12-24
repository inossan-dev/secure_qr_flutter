/// QRValidationResult
///
/// Cette classe représente le résultat complet d'une validation de QR code.
/// Elle adopte une approche immutable où chaque instance représente un état
/// final et immuable de validation. Cette approche garantit la cohérence des
/// données tout au long du cycle de vie de l'application.
///
/// Le résultat de validation peut se trouver dans l'un des trois états suivants :
/// 1. Valide : Le QR code est authentique et ses données sont accessibles
/// 2. Invalide : Le QR code n'a pas passé les contrôles de validation
/// 3. Expiré : Le QR code était valide mais sa période de validité est dépassée
///
/// Exemple d'utilisation :
/// ```dart
/// // Création d'un résultat valide
/// final validResult = QRValidationResult.valid({
///   'userId': '123',
///   'accessLevel': 'admin'
/// });
///
/// // Vérification et utilisation du résultat
/// if (validResult.isValid) {
///   final userData = validResult.data;
///   // Traitement des données...
/// } else if (validResult.isExpired) {
///   // Gestion de l'expiration...
/// } else {
///   print('Erreur : ${validResult.error}');
/// }
/// ```
class QRValidationResult {
  /// Indique si le QR code est valide.
  ///
  /// Cette propriété est true uniquement si toutes les validations
  /// ont réussi (authentification, signature, règles métier, etc.)
  /// et que le QR code n'est pas expiré.
  final bool isValid;

  /// Indique si le QR code est expiré.
  ///
  /// Cette propriété permet de distinguer spécifiquement le cas
  /// d'expiration des autres types d'invalidité. Un QR code expiré
  /// aura toujours isValid = false, mais tous les QR codes invalides
  /// ne sont pas nécessairement expirés.
  final bool isExpired;

  /// Message d'erreur expliquant pourquoi la validation a échoué.
  ///
  /// Cette propriété est null si le QR code est valide. Dans le cas
  /// contraire, elle contient une description claire de la raison
  /// de l'échec, qu'il s'agisse d'une expiration ou d'une autre erreur.
  final String? error;

  /// Données extraites du QR code après validation réussie.
  ///
  /// Cette propriété contient les données métier du QR code uniquement
  /// si celui-ci est valide. Elle est null dans tous les autres cas.
  /// Le type Map<String, dynamic> permet une grande flexibilité dans
  /// la structure des données stockées.
  final Map<String, dynamic>? data;

  /// Constructeur privé permettant l'initialisation complète d'un résultat.
  ///
  /// Ce constructeur est privé (_) pour forcer l'utilisation des constructeurs
  /// nommés qui représentent les différents cas d'utilisation possibles.
  /// Cela garantit que les instances sont toujours dans un état cohérent.
  ///
  /// [isValid] : État de validité du QR code
  /// [isExpired] : Indique si le QR code est expiré (false par défaut)
  /// [error] : Message d'erreur optionnel
  /// [data] : Données du QR code si valide
  QRValidationResult._({
    required this.isValid,
    this.isExpired = false,
    this.error,
    this.data,
  });

  /// Crée un résultat représentant un QR code valide.
  ///
  /// Ce constructeur est utilisé quand toutes les validations ont réussi
  /// et que les données peuvent être exploitées en toute sécurité.
  ///
  /// [data] : Les données extraites du QR code
  ///
  /// Returns : Une instance représentant un QR code valide
  factory QRValidationResult.valid(Map<String, dynamic> data) {
    return QRValidationResult._(isValid: true, data: data);
  }

  /// Crée un résultat représentant un QR code invalide.
  ///
  /// Ce constructeur est utilisé quand la validation échoue pour une raison
  /// autre que l'expiration (signature invalide, format incorrect, etc.).
  ///
  /// [error] : Description de la raison de l'échec
  ///
  /// Returns : Une instance représentant un QR code invalide
  factory QRValidationResult.invalid(String error) {
    return QRValidationResult._(isValid: false, error: error);
  }

  /// Crée un résultat représentant un QR code expiré.
  ///
  /// Ce constructeur spécialise le cas d'invalidité pour l'expiration,
  /// permettant un traitement spécifique de ce cas particulier.
  ///
  /// Returns : Une instance représentant un QR code expiré
  factory QRValidationResult.expired() {
    return QRValidationResult._(
      isValid: false,
      isExpired: true,
      error: "QR code expiré",
    );
  }
}