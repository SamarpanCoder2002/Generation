import 'package:encrypt/encrypt.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/services/local_data_management.dart';

class Secure {
  static final Key _key =
      Key.fromBase64(DataManagement.getEnvData(EnvFileKey.encryptKey) ?? '');
  static final IV _iv = IV.fromLength(16);
  static final Encrypter _makeEncryption =
      Encrypter(AES(_key, mode: AESMode.ctr, padding: null));

  static String? encode(String? plainText) {
    if (plainText == null) return null;
    final Encrypted encrypted = _makeEncryption.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decode(String? encodedStringForm) {
    try {
      if (encodedStringForm == null) return '';

      final String decrypted =
          _makeEncryption.decrypt64(encodedStringForm, iv: _iv);
      return decrypted;
    } catch (e) {
      return encodedStringForm ?? '';
    }
  }
}
