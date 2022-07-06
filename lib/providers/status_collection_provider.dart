import 'package:flutter/material.dart';
import 'package:generation/services/debugging.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:intl/intl.dart';

import '../config/countable_data_collection.dart';
import '../model/activity_model.dart';

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

  bool eligibleForShowDateTime(ActivityModel? _currentActivityData) {
    try {
      DateFormat format = DateFormat("dd MMMM, yyyy hh:mm a");
      var formattedDateTime = format
          .parse("${_currentActivityData!.date} ${_currentActivityData.time}");
      final Duration _diffDateTime =
          DateTime.now().difference(formattedDateTime);

      return _diffDateTime.inHours < TimeCollection.activitySustainTimeInHour;
    } catch (e) {
      debugShow('Error in eligibleForShowDatetime: $e');
      return true;
    }
  }
}
