import 'package:permission_handler/permission_handler.dart';

Future<bool> recordingPermission() async{
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
}

Future<bool> storagePermission() async{
  final status = await Permission.storage.request();
  return status == PermissionStatus.granted;
}