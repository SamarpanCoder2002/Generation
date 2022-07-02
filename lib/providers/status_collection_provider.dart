import 'package:flutter/material.dart';
import 'package:generation/services/local_database_services.dart';

class StatusCollectionProvider extends ChangeNotifier {
  final LocalStorage _localStorage = LocalStorage();
  Map<String, dynamic> _currAccData = {};
  List<dynamic> _activityDataCollection = [];

  initialize() async {
    final _currAccData = await _localStorage.getDataForCurrAccount();
    this._currAccData = _currAccData;
  }

  Map<String, dynamic> getCurrentAccData() => _currAccData;

  setFreshData(incomingActivityData) {
    if (incomingActivityData == null) return;

    _activityDataCollection = incomingActivityData;
    notifyListeners();
  }

  addNewData(incomingNewData) {
    if (incomingNewData == null) return;

    _activityDataCollection = [..._activityDataCollection, ...incomingNewData];
    notifyListeners();
  }

  getData() => _activityDataCollection;

  getDataLength() => _activityDataCollection.length;
}
