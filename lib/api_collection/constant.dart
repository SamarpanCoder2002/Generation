import '../config/text_collection.dart';
import '../services/local_data_management.dart';

class API{
  static get baseUrl => DataManagement.getEnvData(EnvFileKey.baseUrl) ?? "";
  static const signIn = "auth/signin";
}