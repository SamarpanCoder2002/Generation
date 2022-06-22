import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/storage/storage_provider.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/system_file_management.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../services/debugging.dart';

class StorageAudioAndDocumentCollectionScreen extends StatelessWidget {
  final bool isAudio;

  const StorageAudioAndDocumentCollectionScreen({Key? key, this.isAudio = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: _getBody(context),
    );
  }

  _getBody(BuildContext context) {
    if (isAudio &&
        Provider.of<StorageProvider>(context).getAudioCollection().isEmpty) {
      debugShow("here");
      return _emptyMedia('No Audios Found', context);
    }

    if (!isAudio &&
        Provider.of<StorageProvider>(context).getDocumentCollection().isEmpty) {
      return _emptyMedia('No Documents Found', context);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: isAudio
            ? Provider.of<StorageProvider>(context).getAudioCollection().length
            : Provider.of<StorageProvider>(context)
                .getDocumentCollection()
                .length,
        itemBuilder: (_, index) => _particularData(index, context),
      ),
    );
  }

  _particularData(int index, BuildContext context) {
    String _audioDocFile = isAudio
        ? Provider.of<StorageProvider>(context).getAudioCollection()[index]
            ['message']
        : Provider.of<StorageProvider>(context).getDocumentCollection()[index]
            ['message'];

    _audioDocFile = Secure.decode(_audioDocFile);

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () async => await SystemFileManagement.openFile(_audioDocFile),
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage(isAudio
                          ? "assets/images/audio.png"
                          : "assets/images/document.png"))),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 80,
              child: Text(
                _audioDocFile.split("/").last,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.terminalTextStyle.copyWith(
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightChatConnectionTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _emptyMedia(String title, BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    return Center(
        child: Text(title,
            style: TextStyleCollection.terminalTextStyle.copyWith(
                fontSize: 16,
                color: AppColors.getModalTextColor(_isDarkMode))));
  }
}
