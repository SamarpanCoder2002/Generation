import 'package:encrypt/encrypt.dart';
import 'package:generation/config/secret_data.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/services/local_data_management.dart';

class Secure {
  static Key _key =
      Key.fromBase64(DataManagement.getEnvData(EnvFileKey.encryptKey) ?? '');
  static IV _iv = IV.fromLength(16);
  static Encrypter _makeEncryption =
      Encrypter(AES(_key, mode: AESMode.ctr, padding: null));

  static String? encode(String? plainText) {
    if (plainText == null) return null;
    final Encrypted encrypted = _makeEncryption.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decode(String? encodedStringForm, {bool initialize = false}) {
    try {
      if (encodedStringForm == null) return '';

      if (initialize) {
        _key = Key.fromBase64(SecretData.encryptKey);
        _iv = IV.fromLength(16);
        _makeEncryption =
            Encrypter(AES(_key, mode: AESMode.ctr, padding: null));
      }

      final String decrypted =
          _makeEncryption.decrypt64(encodedStringForm, iv: _iv);

      return decrypted;
    } catch (e) {
      if (e.toString().contains('NotInitializedError')) {
        return decode(encodedStringForm, initialize: true);
      }

      return encodedStringForm ?? '';
    }
  }
}
