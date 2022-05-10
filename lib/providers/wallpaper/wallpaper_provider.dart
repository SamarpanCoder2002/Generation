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

  List<dynamic> _brightImagesCollection = [];

  List<dynamic> _darkImagesCollection = [];

  List<dynamic> _solidImagesCollection = [];

  getWallpaperCategoryCollection() => _wallpaperCategoryCollection;

  getBrightImagesCollection() => _brightImagesCollection;

  getDarkImagesCollection() => _darkImagesCollection;

  getSolidImagesCollection() => _solidImagesCollection;

  setSolidImagesCollection(List<dynamic> incoming) {
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
