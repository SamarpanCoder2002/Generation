import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/config/time_collection.dart';
import 'package:generation/providers/contacts_provider.dart';
import 'package:generation/providers/sound_record_provider.dart';
import 'package:generation/providers/video_management/video_editing_provider.dart';
import 'package:generation/screens/chat_screens/contacts_management/contacts_collection.dart';
import 'package:generation/screens/chat_screens/maps_support/map_large_showing_dialog.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/native_operations.dart';
import 'package:generation/services/permission_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/images_path_collection.dart';
import '../providers/chat/chat_scroll_provider.dart';
import '../providers/chat/messaging_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/activity/create/create_activity.dart';
import '../screens/common/video_editor_common.dart';
import 'local_data_management.dart';
import 'navigation_management.dart';
import '../types/types.dart';

class InputOption {
  final BuildContext context;

  InputOption(this.context);

  final PermissionManagement _permissionManagement = PermissionManagement();

  pickImageFromGallery({int imageQuality = 50}) async {
    final List<XFile>? _pickedImagesCollection =
        await ImagePicker().pickMultiImage(imageQuality: imageQuality);

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
                  .getCurrentTime(),
          MessageData.date:
              Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                  .getCurrentDate()
        }
      });
    }

    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
  }

  pickSingleImageFromGallery(
      {int imageQuality = 50, bool popUpScreen = true}) async {
    final XFile? _pickedImage = await ImagePicker()
        .pickImage(imageQuality: imageQuality, source: ImageSource.gallery);

    if (_pickedImage == null) {
      return;
    }

    if (popUpScreen) Navigator.pop(context);

    return File(_pickedImage.path).path;
  }

  takeImageFromCamera({bool forChat = true, int imageQuality = 50}) async {
    final XFile? pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: imageQuality);

    if (pickedImage == null) {
      return;
    }

    Navigator.pop(context);

    if (!forChat) {
      return File(pickedImage.path).path;
    }

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
                .getCurrentTime(),
        MessageData.date:
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getCurrentDate()
      }
    });

    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
  }

  pickVideoFromCameraAndGallery(
      {bool fromCamera = true,
      bool forChat = true,
      Duration maxDuration = const Duration(seconds: 30)}) async {
    final XFile? pickedVideo = await ImagePicker().pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: fromCamera ? maxDuration : null);

    if (pickedVideo == null) {
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context);

    final thumbnailImage = await NativeCallback()
        .getTheVideoThumbnail(videoPath: File(pickedVideo.path).path);

    if (!forChat) {
      final Map<String, dynamic> data = {};
      data["thumbnail"] = thumbnailImage;
      data["videoPath"] = File(pickedVideo.path).path;
      return data;
    }

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
        MessageData.date:
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getCurrentDate(),
        MessageData.additionalData: {"thumbnail": thumbnailImage}
      }
    });

    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
  }

  documentPickFromDevice() async {
    final List<String> _allowedExtensions = [
      'pdf',
      'doc',
      'docx',
      'ppt',
      'pptx',
      'c',
      'cpp',
      'py',
      'txt',
      'pptx',
    ];

    await _commonFilePickingSection(
        _allowedExtensions, ChatMessageType.document);
  }

  audioPickFromDevice({bool forChat = true}) async {
    final List<String> _allowedExtensions = [
      'mp3',
      'aac',
      'm4a',
      'wav',
    ];

    if (forChat) {
      _commonFilePickingSection(_allowedExtensions, ChatMessageType.audio);
    } else {
      return _commonFilePickingSection(
          _allowedExtensions, ChatMessageType.audio,
          forChat: forChat);
    }
  }

  _commonFilePickingSection(
      List<String> _allowedExtensions, ChatMessageType chatMessageType,
      {bool forChat = true}) async {
    try {
      final storagePermissionResponse =
          await _permissionManagement.storagePermission();
      if (!storagePermissionResponse) {
        Navigator.pop(context);
        return;
      }

      final FilePickerResult? filePickerResult =
          await FilePicker.platform.pickFiles(
        dialogTitle: "Choose Files",
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: forChat ? true : false,
      );

      if (filePickerResult == null || filePickerResult.files.isEmpty) return;

      if (!forChat) return filePickerResult.files[0];

      Navigator.pop(context);

      for (final pickedFile in filePickerResult.files) {
        if (_allowedExtensions.contains(pickedFile.extension)) {
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .setSingleNewMessage({
            DateTime.now().toString(): {
              MessageData.type: chatMessageType.toString(),
              MessageData.message: File(pickedFile.path!).path,
              MessageData.holder:
                  Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                      .getMessageHolderType()
                      .toString(),
              MessageData.time:
                  Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                      .getCurrentTime(),
              MessageData.date:
                  Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                      .getCurrentDate(),
              MessageData.additionalData: {
                "extension-for-document": pickedFile.extension.toString()
              }
            }
          });
        }
      }

      Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
    } catch (e) {
      print("Error in Document File Picking: $e");
    }
  }

  showCurrentLocationInGoogleMaps(BuildContext oldStackContext) async {
    final _locationData = await _getCurrentLocation(oldStackContext);

    if (_locationData.isEmpty) {
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ShowMapInLargeForm(locationData: _locationData)));
  }

  Future<Map<String, dynamic>> _getCurrentLocation(
      BuildContext oldStackContext) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      showToast(oldStackContext,
          title: "Location Service is not Enabled",
          toastIconType: ToastIconType.error);
      return {};
    }

    final bool _locationActivationStatus =
        await _permissionManagement.locationPermission();

    if (!_locationActivationStatus) {
      showToast(oldStackContext,
          title: "Location Permission not granted",
          toastIconType: ToastIconType.error);

      return {};
    }

    showToast(oldStackContext,
        title: "Map will show within few seconds",
        toastIconType: ToastIconType.info,
        toastDuration: 12);

    final _locationData = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true);

    final Map<String, dynamic> _coordinate = {};
    _coordinate["latitude"] = _locationData.latitude;
    _coordinate["longitude"] = _locationData.longitude;
    return _coordinate;
  }

  sendLocationService(double _latitude, double _longitude) {
    Navigator.pop(context);

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setSingleNewMessage({
      DateTime.now().toString(): {
        MessageData.type: ChatMessageType.location.toString(),
        MessageData.message: {"latitude": _latitude, "longitude": _longitude},
        MessageData.holder:
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getMessageHolderType()
                .toString(),
        MessageData.time:
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getCurrentTime(),
        MessageData.date:
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getCurrentDate(),
      }
    });

    Navigator.pop(context);
    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
  }

  getContacts() async {
    final isPermissionGiven = await _permissionManagement.contactPermission();

    if (!isPermissionGiven) {
      return;
    }

    final List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);

    Provider.of<ContactsProvider>(context, listen: false)
        .setPhoneContacts(contacts);

    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ContactsCollection()));
  }

  takeInputForContactName(
      {required TextEditingController contactNameController,
      required String phoneNumber,
      required String phoneNumberLabel,
      required bool isDarkMode}) {
    _heading() => Center(
          child: Text(
            "Contact Name",
            style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                fontSize: 18, color: AppColors.getModalTextColor(isDarkMode)),
          ),
        );

    _contactNameInputSection() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            style: TextStyleCollection.terminalTextStyle.copyWith(
                fontSize: 14, color: AppColors.getModalTextColor(isDarkMode)),
            controller: contactNameController,
            autofocus: true,
            cursorColor: AppColors.getModalTextColor(isDarkMode),
            decoration: InputDecoration(
              hintText: "Enter Contact Name",
              hintStyle: TextStyleCollection.terminalTextStyle.copyWith(
                  color:
                      AppColors.getModalTextColor(isDarkMode).withOpacity(0.6),
                  fontSize: 14),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.getModalTextColor(isDarkMode)
                        .withOpacity(0.8)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.getModalTextColor(isDarkMode)
                        .withOpacity(0.8)),
              ),
            ),
          ),
        );

    _onSaveButtonPressed() async {
      if (contactNameController.text.isEmpty) {
        showToast(context,
            height: 50,
            title: "Please Give a Contact Name",
            toastIconType: ToastIconType.info);
        return;
      }

      await _addNumberInContact(
          phoneNumber, contactNameController.text, phoneNumberLabel);
      Navigator.pop(context);

      /// Show Success toast Message
      showToast(context,
          title: "Contact Saved Successfully",
          height: 50,
          toastIconType: ToastIconType.success);
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
            color: AppColors.getModalColor(isDarkMode),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _heading(),
                const SizedBox(
                  height: 20,
                ),
                _contactNameInputSection(),
                const SizedBox(
                  height: 20,
                ),
                commonElevatedButton(
                    btnText: "Save",
                    onPressed: _onSaveButtonPressed,
                    bgColor: AppColors.darkBorderGreenColor),
              ],
            )));
  }

  phoneNumberOpeningOptions(context,
      {required String phoneNumber, required bool isDarkMode}) {
    openSms() async {
      try {
        await launch("sms:$phoneNumber");
        Navigator.pop(context);
      } catch (e) {
        /// Show Error Toast
      }
    }

    callToNumber() async {
      try {
        await launch("tel:$phoneNumber");
        Navigator.pop(context);
      } catch (e) {
        /// Show Error Toast
      }
    }

    openInWhatsapp() async {
      try {
        await launch("whatsapp://send?phone=$phoneNumber");
        Navigator.pop(context);
      } catch (e) {
        /// Show Error Toast
      }
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              color: AppColors.getModalColorSecondary(isDarkMode),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonElevatedButton(
                      btnText: "Sms",
                      onPressed: openSms,
                      bgColor: AppColors.getElevatedBtnColor(isDarkMode)),
                  commonElevatedButton(
                      btnText: "Call",
                      onPressed: callToNumber,
                      bgColor: AppColors.getElevatedBtnColor(isDarkMode)),
                  commonElevatedButton(
                      btnText: "Whatsapp",
                      onPressed: openInWhatsapp,
                      bgColor: AppColors.getElevatedBtnColor(isDarkMode)),
                ],
              ),
            ));
  }

  _addNumberInContact(
      String phoneNumber, String name, String numberLabel) async {
    final isPermissionGiven = await _permissionManagement.contactPermission();

    if (!isPermissionGiven) {
      return;
    }

    final Contact contact = Contact();
    contact.givenName = name;
    contact.familyName = "";
    contact.phones = [Item(label: numberLabel, value: phoneNumber)];
    await ContactsService.addContact(contact);
    print("Here");
  }

  Future sendSupportMail(String subject, String body) async {
    final supportMail = DataManagement.getEnvData(EnvFileKey.supportMail);

    print("Support Mail: $supportMail");

    final Uri params = Uri(
      scheme: 'mailto',
      path: supportMail,
      query: 'subject=$subject&body=$body',
    );

    final String url = params.toString();
    try {
      await launch(url);
    } catch (e) {
      debugPrint('Support Mail Sending Error: ${e.toString()}');
    }
  }

  Future<void> shareTextContent(String textToShare) async =>
      await Share.share(textToShare);

  _onGalleryPressed() async {
    final data =
        await pickVideoFromCameraAndGallery(fromCamera: false, forChat: false);

    if (data == null) return;
    _commonVideoNavigationForActivity(data, VideoType.file);
  }

  _onCameraPressed() async {
    final data = await pickVideoFromCameraAndGallery(forChat: false);

    if (data == null) return;
    _commonVideoNavigationForActivity(data, VideoType.file);
  }

  makeVideoActivity(bool _isDarkMode) {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              color: AppColors.getModalColorSecondary(_isDarkMode),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonElevatedButton(
                      btnText: "Camera",
                      onPressed: _onCameraPressed,
                      bgColor: AppColors.getElevatedBtnColor(_isDarkMode)),
                  commonElevatedButton(
                      btnText: "Gallery",
                      onPressed: _onGalleryPressed,
                      bgColor: AppColors.getElevatedBtnColor(_isDarkMode))
                ],
              ),
            ));
  }

  _commonVideoNavigationForActivity(dynamic data, VideoType videoType) async {
    final duration =
        await Provider.of<VideoEditingProvider>(context, listen: false)
            .getVideoDuration(File(data["videoPath"]));

    if (duration.inSeconds <= Timings.videoDurationInSec) {
      Navigation.intent(
          context,
          CreateActivity(activityContentType: ActivityContentType.video, data: {
            "file": File(data["videoPath"]),
            "thumbnail": data["thumbnail"],
            "duration": duration.inSeconds.ceil().toString()
          }));
    } else {
      Navigation.intent(
          context,
          VideoEditingScreen(
              path: data["videoPath"],
              videoType: videoType,
              thumbnailPath: data["thumbnail"]));
    }
  }

  activityImageFromCamera() async {
    final _imagePath = await takeImageFromCamera(forChat: false);

    if (_imagePath == null) return;

    commonCreateActivityNavigation(ActivityContentType.image,
        data: {"path": _imagePath, "type": ImageType.file});
  }

  activityImageFromGallery() async {
    final _imagePath = await pickSingleImageFromGallery();

    if (_imagePath == null) return;

    commonCreateActivityNavigation(ActivityContentType.image,
        data: {"path": _imagePath, "type": ImageType.file});
  }

  commonCreateActivityNavigation(ActivityContentType activityContentType,
      {required Map<String, dynamic> data}) {
    print("Navigation at");

    Navigation.intent(
        context,
        CreateActivity(
          activityContentType: activityContentType,
          data: data,
        ));
  }

  void makeAudioActivity() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              color: AppColors.getBgColor(_isDarkMode),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonElevatedButton(
                      btnText: "Record",
                      onPressed: _recordForActivity,
                      bgColor: AppColors.getElevatedBtnColor(_isDarkMode)),
                  commonElevatedButton(
                      btnText: "Pick",
                      onPressed: _pickAudioForActivity,
                      bgColor: AppColors.getElevatedBtnColor(_isDarkMode)),
                ],
              ),
            ));
  }

  _recordForActivity() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    Navigator.pop(context);
    _deleteRecording() => IconButton(
          icon: const Icon(
            Icons.delete_outline_outlined,
            color: AppColors.lightRedColor,
          ),
          onPressed: () {
            Provider.of<SoundRecorderProvider>(context, listen: false)
                .stopRecording();
            Navigator.pop(context);
          },
        );

    _recordingWaveForm() => SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: MusicVisualizer(
            barCount: 30,
            colors: WaveForm.colors,
            duration: Timings.waveFormDuration,
          ),
        );

    _recordingVoiceSending() => IconButton(
          icon: Image.asset(
            IconImages.sendImagePath,
            width: 25,
            color: AppColors.getIconColor(_isDarkMode),
          ),
          onPressed: () async {
            final _voiceRecordPath =
                await Provider.of<SoundRecorderProvider>(context, listen: false)
                    .stopRecording();

            final int? durationInSec =
                await Provider.of<SongManagementProvider>(context,
                        listen: false)
                    .getDurationInSec(_voiceRecordPath);

            Navigator.pop(context);
            Navigator.pop(context);

            print("Duration in sec: $durationInSec");

            if (durationInSec == null ||
                durationInSec > Timings.audioDurationInSec) {
              showToast(context,
                  title:
                      "Toast Duration greater than ${Timings.audioDurationInSec} sec",
                  toastIconType: ToastIconType.warning);
              return;
            }

            commonCreateActivityNavigation(ActivityContentType.audio, data: {
              "path": _voiceRecordPath,
              "duration": durationInSec.toString()
            });
          },
        );

    _whenRecordingWidget() => Container(
          color: AppColors.getBgColor(_isDarkMode),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _deleteRecording(),
              _recordingWaveForm(),
              _recordingVoiceSending(),
            ],
          ),
        );

    _whenNonRecordingWidget() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            commonElevatedButton(
                btnText: "Start",
                onPressed: () =>
                    Provider.of<SoundRecorderProvider>(context, listen: false)
                        .startRecording()
                        .then((value) => _recordForActivity()),
                bgColor: AppColors.getElevatedBtnColor(_isDarkMode)),
            Text(
              "Audio Length Restricted to ${Timings.audioDurationInSec} sec",
              style: TextStyleCollection.terminalTextStyle.copyWith(
                  fontSize: 14,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            )
          ],
        );

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) {
          final bool _isRecording =
              Provider.of<SoundRecorderProvider>(context).getRecordingStatus();

          return Container(
            color: AppColors.getBgColor(_isDarkMode),
            padding: EdgeInsets.all(_isRecording ? 0 : 10),
            child: _isRecording
                ? _whenRecordingWidget()
                : _whenNonRecordingWidget(),
          );
        });
  }

  void _pickAudioForActivity() async {
    final file = await audioPickFromDevice(forChat: false);

    if (file == null) return;

    print("File: ${file.path}");

    final int? durationInSec =
        await Provider.of<SongManagementProvider>(context, listen: false)
            .getDurationInSec(File(file.path).path);

    print("Duration in Sec: $durationInSec");

    if (durationInSec == null || durationInSec > Timings.audioDurationInSec) {
      showToast(context,
          title:
              "Toast Duration greater than ${Timings.audioDurationInSec} sec",
          toastIconType: ToastIconType.warning);
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context);

    commonCreateActivityNavigation(ActivityContentType.audio, data: {
      "path": File(file.path).path,
      "duration": durationInSec.toString()
    });
  }
}
