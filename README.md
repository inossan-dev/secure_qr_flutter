# secure_qr_flutter

Une librairie Flutter pour générer des QR codes sécurisés avec chiffrement et auto-régénération.

## Fonctionnalités

- ⏱️ Auto-régénération des QR codes
- 🎨 Widget Flutter personnalisable
- 🔄 Validation temporelle des codes
- 🔐 Chiffrement AES des données (optionnel)
- ✍️ Signature numérique pour l'intégrité des données (optionnel)

## Installation

```yaml
dependencies:
  secure_qr_flutter: ^1.0.0
```

## Utilisation

### Configuration de base

```dart
final config = SecureQRConfig(
  secretKey: "votre_clé_secrète_32_caractères",
  validityDuration: Duration(minutes: 5),
  enableEncryption: true,
  enableSignature: true,
);
```

### Génération simple d'un QR code

```dart
final generator = SecureQRGenerator(config);
final qrData = generator.generateQRPayload({
  'userId': '12345',
  'access': 'full',
});
```

### Utilisation du widget auto-régénérant

```dart
AutoRegeneratingQR(
  data: {'userId': '12345'},
  generator: generator,
  regenerationInterval: Duration(minutes: 4),
  builder: (qrData) => QrImage(
    data: qrData,
    size: 200,
  ),
)
```

### Validation d'un QR code

```dart
final result = generator.validateQRPayload(scannedData);
if (result.isValid) {
  print('Données valides : ${result.data}');
} else if (result.isExpired) {
  print('QR code expiré');
} else {
  print('Erreur : ${result.error}');
}
```

## Configuration avancée

### Mode debug

```dart
final debugConfig = SecureQRConfig(
  secretKey: "clé_test",
  enableEncryption: false,
  enableSignature: true,
);
```

## Licence

MIT License - voir le fichier LICENSE pour plus de détails.