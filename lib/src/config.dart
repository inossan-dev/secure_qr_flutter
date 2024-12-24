class SecureQRConfig {
  final String secretKey;
  final Duration validityDuration;
  final bool enableEncryption;
  final bool enableSignature;

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