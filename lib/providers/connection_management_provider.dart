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

  setUpdatedIndex(incomingIndex, {bool movePageView = false}){
    _currentIndex = incomingIndex;
    notifyListeners();

    if(movePageView) changePageView(incomingIndex);
  }

  changePageView(incomingIndex){
    _pageController.animateToPage(incomingIndex, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    notifyListeners();
  }
}