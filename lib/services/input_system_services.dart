import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/services/native_operations.dart';
import 'package:generation/types/types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/chat_scroll_provider.dart';
import '../providers/messaging_provider.dart';

class InputOption {
  final BuildContext context;

  InputOption(this.context);

  pickImageFromGallery() async {
    final List<XFile>? _pickedImagesCollection =
        await ImagePicker().pickMultiImage(imageQuality: 70);

    if (_pickedImagesCollection == null || _pickedImagesCollection.isEmpty) {
      return;
    }

    Navigator.pop(context);

    for (final pickedImage in _pickedImagesCollection) {
      Provider.of<ChatBoxMessagingProvider>(context, listen: false)
          .setSingleNewMessage({
        DateTime.now().toString(): {
          MessageData.type: ChatMessageType.image.toString(),
          MessageData.message: File(pickedImage.path).path,
          MessageData.holder:
              Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                  .getMessageHolderType()
                  .toString(),
          MessageData.time:
              Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                  .getCurrentTime()
        }
      });
    }

    Provider.of<ChatScrollProvider>(context, listen: false)
        .animateToBottom();
  }
  
  takeImageFromCamera() async{
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);

    if (pickedImage == null) {
      return;
    }

    Navigator.pop(context);
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setSingleNewMessage({
      DateTime.now().toString(): {
        MessageData.type: ChatMessageType.image.toString(),
        MessageData.message: File(pickedImage.path).path,
        MessageData.holder:
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getMessageHolderType()
            .toString(),
        MessageData.time:
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getCurrentTime()
      }
    });

    Provider.of<ChatScrollProvider>(context, listen: false)
        .animateToBottom();

  }

  pickVideoFromCameraAndGallery({bool fromCamera = true}) async{
    final XFile? pickedVideo = await ImagePicker().pickVideo(source: fromCamera?ImageSource.camera:ImageSource.gallery);

    if (pickedVideo == null) {
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context);

    final thumbnailImage = await NativeCallback().getTheVideoThumbnail(videoPath: File(pickedVideo.path).path);

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setSingleNewMessage({
      DateTime.now().toString(): {
        MessageData.type: ChatMessageType.video.toString(),
        MessageData.message: File(pickedVideo.path).path,
        MessageData.holder:
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getMessageHolderType()
            .toString(),
        MessageData.time:
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getCurrentTime(),
        MessageData.thumbnail: thumbnailImage
      }
    });

    Provider.of<ChatScrollProvider>(context, listen: false)
        .animateToBottom();
  }
}
