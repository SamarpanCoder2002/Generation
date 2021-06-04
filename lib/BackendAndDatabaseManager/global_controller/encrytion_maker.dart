import 'package:encrypt/encrypt.dart';

class EncryptionMaker {
  static final Key _key =
      Key.fromBase64('Unique Key Here');
  final _iv = IV.fromLength(16);

  Encrypter _makeEncryption;

  EncryptionMaker() {
    this._makeEncryption = Encrypter(AES(_key, mode: AESMode.ctr, padding: null));
  }

  String encryptionMaker(String plainText) {
    final Encrypted encrypted = _makeEncryption.encrypt(plainText, iv: this._iv);
    print('Encrypted is: ${encrypted.base64}');
    return encrypted.base64;
  }

  String decryptionMaker(String encodedStringForm) {
    final String decrypted =
        this._makeEncryption.decrypt64(encodedStringForm, iv: this._iv);
    return decrypted;
  }
}
