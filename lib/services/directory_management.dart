import 'dart:io';

import 'package:generation/config/text_collection.dart';
import 'package:path_provider/path_provider.dart';

/// Return Created Dir path
Future<String> makeDirectoryOnce(
    {required String directoryName, bool makeDirPrivate = false}) async {
  final Directory? directory = await getExternalStorageDirectory();

  final String folderNameFormat =
      makeDirPrivate ? "/.$directoryName/" : "/$directoryName/";

  final Directory newDir = await Directory(directory!.path + folderNameFormat)
      .create(); // This directory will create Once in whole Application

  return newDir.path;
}

Future<String> createVoiceStoreDir() async{
  return await makeDirectoryOnce(directoryName: DirectoryName.voiceRecordDir);
}

String createAudioFile({required String dirPath}) => "$dirPath${DateTime.now()}.aac";
