import 'package:flutter/foundation.dart';

debugShow(text){
  if(kDebugMode){
    debugPrint(text.toString());
  } 
}