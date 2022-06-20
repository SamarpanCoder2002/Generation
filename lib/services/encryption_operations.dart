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

      print('\n\n\n\nEncoded String form: $encodedStringForm\n\n\n\n');

      print('Initialization Value: $initialize\n\n\n\n');

      if (initialize) {
        _key = Key.fromBase64(SecretData.encryptKey);
        _iv = IV.fromLength(16);
        _makeEncryption =
            Encrypter(AES(_key, mode: AESMode.ctr, padding: null));

        print(
            '\n\n\n\nAfter initialize make Encryption value: $_makeEncryption\n\n\n\n');
      }

      final String decrypted =
          _makeEncryption.decrypt64(encodedStringForm, iv: _iv);

      if (initialize) {
        print('Initiailize: $initialize    DECCRYPTED VALUE: $decrypted');
      }

      return decrypted;
    } catch (e) {
      print('Decoding Error: $e');

      if (e.toString().contains('NotInitializedError')) {
        return decode(encodedStringForm, initialize: true);
      }

      return encodedStringForm ?? '';
    }
  }
}
