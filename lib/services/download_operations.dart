import 'package:dio/dio.dart';
import 'package:generation/services/directory_management.dart';

class DownloadOperations {
  final Dio _dio = Dio();

  Future<String> downloadWallpaper(String url) async {
    final _dirPath = await createWallpaperStoreDir();
    final _wallpaperStorePath = createWallpaperFile(dirPath: _dirPath);

    await _dio.download(url, _wallpaperStorePath);

    return _wallpaperStorePath;
  }
}
