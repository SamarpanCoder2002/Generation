import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/providers_collection.dart';
import 'package:generation/screens/entry_screens/splash_screen.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  await DataManagement.loadEnvData();
  runApp(const GenerationEntry());
}

class GenerationEntry extends StatelessWidget {
  const GenerationEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providersCollection,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Generation',
        theme: ThemeData(
            fontFamily: 'Poppins',
            bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: AppColors.transparentColor)),
        builder: (context, child) => MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

_initializeFirebase(){
  Firebase.initializeApp();
}
