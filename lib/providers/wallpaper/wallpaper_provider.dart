import 'package:flutter/material.dart';
import 'package:generation/types/types.dart';

class WallpaperProvider extends ChangeNotifier {
  List<dynamic> _wallpaperCategoryCollection = [
    {
      "category": "Bright",
      "image":
          "https://images.pexels.com/photos/1420440/pexels-photo-1420440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
      "type": WallpaperType.bright
    },
    {
      "category": "Dark",
      "image":
          "https://images.pexels.com/photos/2469122/pexels-photo-2469122.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
      "type": WallpaperType.dark
    },
    {
      "category": "Solid Color",
      "image":
          "https://images.pexels.com/photos/1260727/pexels-photo-1260727.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
      "type": WallpaperType.solidColor
    },
    {
      "category": "My Photos",
      "image":
          "https://images.pexels.com/photos/8852732/pexels-photo-8852732.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
      "type": WallpaperType.myPhotos
    },
  ];

  List<dynamic> _brightImagesCollection = [
    "https://images.pexels.com/photos/1129413/pexels-photo-1129413.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/1496373/pexels-photo-1496373.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/1078983/pexels-photo-1078983.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/757889/pexels-photo-757889.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/916337/pexels-photo-916337.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/4740583/pexels-photo-4740583.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/2860705/pexels-photo-2860705.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/922472/pexels-photo-922472.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/1496372/pexels-photo-1496372.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3273786/pexels-photo-3273786.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"
  ];

  List<dynamic> _darkImagesCollection = [
    "https://images.pexels.com/photos/3617500/pexels-photo-3617500.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3222255/pexels-photo-3222255.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/207353/pexels-photo-207353.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/5641973/pexels-photo-5641973.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
  ];

  List<dynamic> _solidImagesCollection = [

  ];

  getWallpaperCategoryCollection() => _wallpaperCategoryCollection;

  getBrightImagesCollection() => _brightImagesCollection;

  getDarkImagesCollection() => _darkImagesCollection;

  getSolidImagesCollection() => _solidImagesCollection;

  setSolidImagesCollection(List<dynamic> incoming){
    _solidImagesCollection = incoming;
    notifyListeners();
  }

  setWallpaperCategoryCollection(List<dynamic> incoming) {
    _wallpaperCategoryCollection = incoming;
    notifyListeners();
  }

  setBrightImagesCollection(List<dynamic> incoming) {
    _brightImagesCollection = incoming;
    notifyListeners();
  }

  setDarkImagesCollection(List<dynamic> incoming) {
    _darkImagesCollection = incoming;
    notifyListeners();
  }
}
