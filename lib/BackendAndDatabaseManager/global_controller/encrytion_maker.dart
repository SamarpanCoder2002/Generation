import 'package:encrypt/encrypt.dart';

class EncryptionMaker {
  static final Key _key = Key.fromBase64('UNIQUE-SECURE-KEY');
  static final IV _iv = IV.fromLength(16);

  Encrypter _makeEncryption;

  EncryptionMaker() {
    this._makeEncryption =
        Encrypter(AES(_key, mode: AESMode.ctr, padding: null));
  }

  String encryptionMaker(String plainText) {
    final Encrypted encrypted = _makeEncryption.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptionMaker(String encodedStringForm) {
    final String decrypted =
        this._makeEncryption.decrypt64(encodedStringForm, iv: _iv);
    return decrypted;
  }
}
