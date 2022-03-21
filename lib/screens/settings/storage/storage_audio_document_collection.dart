import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/storage/storage_provider.dart';
import 'package:generation/services/system_file_management.dart';
import 'package:provider/provider.dart';

class StorageAudioAndDocumentCollectionScreen extends StatelessWidget {
  final bool isAudio;

  const StorageAudioAndDocumentCollectionScreen({Key? key, this.isAudio = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: Provider.of<StorageProvider>(context)
              .getImagesCollection()
              .length,
          itemBuilder: (_, index) => _particularAudioData(index, context),
        ),
      ),
    );
  }

  _particularAudioData(int index, BuildContext context) {
    final String _audioFile =
        Provider.of<StorageProvider>(context).getImagesCollection()[index];

    return InkWell(
      onTap: () async => await SystemFileManagement.openFile(_audioFile),
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
              width: 20,
            ),
            Text(
              _audioFile.split("/").last.split("?").first,
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
