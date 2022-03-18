import 'package:flutter/material.dart';
import 'package:generation/providers/providers_collection.dart';
import 'package:generation/screens/entry_screens/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
        ),
        builder: (context, child) => MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
