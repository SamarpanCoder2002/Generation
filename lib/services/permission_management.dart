import 'package:permission_handler/permission_handler.dart';

class PermissionManagement{
  Future<bool> recordingPermission() async{
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> storagePermission() async{
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> locationPermission() async{
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<bool> contactPermission() async{
    final status = await Permission.contacts.request();
    return status == PermissionStatus.granted;
  }
}