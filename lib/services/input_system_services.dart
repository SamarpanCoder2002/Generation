import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/contacts_provider.dart';
import 'package:generation/screens/chat_screens/contacts_management/contacts_collection.dart';
import 'package:generation/screens/chat_screens/maps_support/map_large_showing_dialog.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/native_operations.dart';
import 'package:generation/services/permission_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/chat_scroll_provider.dart';
import '../providers/messaging_provider.dart';

class InputOption {
  final BuildContext context;

  InputOption(this.context);

  final PermissionManagement _permissionManagement = PermissionManagement();

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

    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
  }

  pickSingleImageFromGallery()async{
    final XFile? _pickedImage =
        await ImagePicker().pickImage(imageQuality: 70, source: ImageSource.gallery);

    if (_pickedImage == null) {
      return;
    }

    Navigator.pop(context);

    return File(_pickedImage.path).path;
  }

  takeImageFromCamera({bool forChat = true}) async {
    final XFile? pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 70);

    if (pickedImage == null) {
      return;
    }

    Navigator.pop(context);

    if(!forChat){
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
                .getCurrentTime()
      }
    });

    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
  }

  pickVideoFromCameraAndGallery({bool fromCamera = true}) async {
    final XFile? pickedVideo = await ImagePicker().pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedVideo == null) {
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context);

    final thumbnailImage = await NativeCallback()
        .getTheVideoThumbnail(videoPath: File(pickedVideo.path).path);

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

  audioPickFromDevice() async {
    final List<String> _allowedExtensions = [
      'mp3',
      'aac',
      'm4a',
      'wav',
    ];

    await _commonFilePickingSection(_allowedExtensions, ChatMessageType.audio);
  }

  _commonFilePickingSection(
      List<String> _allowedExtensions, ChatMessageType chatMessageType) async {
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
        allowMultiple: true,
      );

      if (filePickerResult == null || filePickerResult.files.isEmpty) return;

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
      required String phoneNumberLabel}) {
    _heading() => Center(
          child: Text(
            "Contact Name",
            style: TextStyleCollection.secondaryHeadingTextStyle
                .copyWith(fontSize: 18),
          ),
        );

    _contactNameInputSection() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            controller: contactNameController,
            autofocus: true,
            cursorColor: AppColors.pureWhiteColor,
            decoration: InputDecoration(
              hintText: "Enter Contact Name",
              hintStyle: TextStyleCollection.terminalTextStyle.copyWith(
                  color: AppColors.pureWhiteColor.withOpacity(0.6),
                  fontSize: 14),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.pureWhiteColor.withOpacity(0.8)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.pureWhiteColor.withOpacity(0.8)),
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
            color: AppColors.oppositeMsgDarkModeColor,
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

  phoneNumberOpeningOptions(context, {required String phoneNumber}) {
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
              color: AppColors.backgroundDarkMode,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonElevatedButton(btnText: "Sms", onPressed: openSms),
                  commonElevatedButton(
                      btnText: "Call", onPressed: callToNumber),
                  commonElevatedButton(
                      btnText: "Whatsapp", onPressed: openInWhatsapp),
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
}
