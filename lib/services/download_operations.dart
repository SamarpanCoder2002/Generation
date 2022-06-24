import 'package:dio/dio.dart';
import 'package:generation/services/directory_management.dart';
import 'package:new_version/new_version.dart';

import 'debugging.dart';

class DownloadOperations {
  final Dio _dio = Dio();

  Future<String> downloadWallpaper(String url) async {
    final _dirPath = await createWallpaperStoreDir();
    final _wallpaperStorePath = createWallpaperFile(dirPath: _dirPath);

    await _dio.download(url, _wallpaperStorePath);

    return _wallpaperStorePath;
  }
}

updateGeneration(context) async {
  try {
    final newVersion = NewVersion();

    final status = await newVersion.getVersionStatus();
    if (status == null) return;

    debugShow(status.releaseNotes);
    debugShow(status.appStoreLink);
    debugShow(status.localVersion);
    debugShow(status.storeVersion);
    debugShow(status.canUpdate.toString());

    if (!status.canUpdate) return;

    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status,
      dialogTitle: 'Update Generation',
      dialogText:
      'Please update this app immediately to enjoy better performances with major bugs fix',
      //allowDismissal: false
    );
  } catch (e) {
    debugShow('Error in updateGeneration: $e');
  }

}
