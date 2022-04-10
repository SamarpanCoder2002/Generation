import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/incoming_data_provider.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:generation/screens/entry_screens/intro_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:generation/services/navigation_management.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../types/types.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription _intentDataStreamSubscription;

  _initialize() async {

    await Provider.of<ThemeProvider>(context, listen: false).initialization();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile>? value) {
      print("Shared MediaStream: $value");
      if (value != null && mounted) {
        final _data = [];

        for (var element in value) {
          _data.add(
              {"path": element.path, "type": _getIncomingMediaType(element)});
        }

        Provider.of<IncomingDataProvider>(context, listen: false)
            .setIncomingData(_data);


      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile>? value) {
      print("Shared Images: $value");
      if (value != null && mounted) {
        final _data = [];

        for (var element in value) {
          _data.add(
              {"path": element.path, "type": _getIncomingMediaType(element)});
        }

        Provider.of<IncomingDataProvider>(context, listen: false)
            .setIncomingData(_data);


      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String? value) {
      print("Shared urls/text coming from outside the app: $value");

      if (value != null && mounted) {
        Provider.of<IncomingDataProvider>(context, listen: false)
            .setIncomingData(value);


      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      print(
          "urls/text coming from outside the app while the app is closed: $value");

      if (value != null && mounted) {
        Provider.of<IncomingDataProvider>(context, listen: false)
            .setIncomingData(value);

      }
    });


      _switchToNextScreen();

  }

  @override
  void initState() {
    _initialize();
    makeScreenCleanView();
    makeScreenStrictPortrait();

    super.initState();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;

    return Scaffold(
      backgroundColor: AppColors.splashScreenColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                AppImages.splashScreenLogo,
                width: MediaQuery.of(context).size.width / 2,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                AppText.appName,
                style: TextStyleCollection.headingTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchToNextScreen() {
    Timer(const Duration(seconds: 1), () {
      Navigation.intentStraight(context, const IntroScreens());
    });
  }
}

_getIncomingMediaType(SharedMediaFile element) {
  if (element.type == SharedMediaType.FILE) {
    return IncomingMediaType.file.toString();
  }
  if (element.type == SharedMediaType.IMAGE) {
    return IncomingMediaType.image.toString();
  }
  if (element.type == SharedMediaType.VIDEO) {
    return IncomingMediaType.video.toString();
  }
}
