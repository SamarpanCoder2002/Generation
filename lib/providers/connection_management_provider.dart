import 'package:flutter/material.dart';

class ConnectionManagementProvider extends ChangeNotifier{
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final List<String> _tabsCollection = [
    "Available Connections",
    "Request",
    "Send"
  ];

  getCurrentIndex() => _currentIndex;

  getPageController() => _pageController;

  getTabsCollection() => _tabsCollection;

  getTabsCollectionLength() => _tabsCollection.length;

  setUpdatedIndex(incomingIndex, context, {bool movePageView = false}){
    _currentIndex = incomingIndex;
    notifyListeners();

    if(movePageView) changePageView(incomingIndex);
  }

  changePageView(incomingIndex){
    try{
      _pageController.animateToPage(incomingIndex, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      notifyListeners();
    }catch(e){
      print("Error in Change View Page under connectionManagementProvider.dart");
    }

  }
}