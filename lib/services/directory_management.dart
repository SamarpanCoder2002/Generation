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

Future<String> createVoiceStoreDir() async => await makeDirectoryOnce(directoryName: DirectoryName.voiceRecordDir);
Future<String> createImageStoreDir() async => await makeDirectoryOnce(directoryName: DirectoryName.imageDir);
Future<String> createVideoStoreDir() async => await makeDirectoryOnce(directoryName: DirectoryName.videoDir);
Future<String> createDocStoreDir() async => await makeDirectoryOnce(directoryName: DirectoryName.docDir);
Future<String> createThumbnailStoreDir() async => await makeDirectoryOnce(directoryName: DirectoryName.thumbnailDir);
Future<String> createWallpaperStoreDir()  async => await makeDirectoryOnce(directoryName: DirectoryName.wallpaperDir, makeDirPrivate: true);


String createAudioFile({required String dirPath}) => "$dirPath${DateTime.now()}.aac";
String createImageFile({required String dirPath}) =>  "$dirPath${DateTime.now()}.png";
String createVideoFile({required String dirPath}) =>  "$dirPath${DateTime.now()}.mp4";
String createDocFile({required String dirPath, required String extension}) =>  "$dirPath${DateTime.now()}.$extension";
String createWallpaperFile({required String dirPath}) => "${dirPath}_wallpaper.png";
