import 'package:flutter/material.dart';
import 'package:generation/services/local_data_management.dart';

class PollShowProvider extends ChangeNotifier {
  Map<String, dynamic> _pollData = {};
  List<String> _pollAnswerCollection = [];
  List<double> _pollAnswerValueCollection = [];
  Map<dynamic, dynamic> _usersWhoVoted = {};
  String? _currentUser;

  setPollData(String incoming, {bool update = true}) {
    _pollData = DataManagement.fromJsonString(incoming);
    _pollAnswerCollection = _getPollAnswers(_pollData);
    _pollAnswerValueCollection = _getPollAnswersScore(_pollData);
    _usersWhoVoted = {};/// Replace with Users Data in future
    _currentUser = "Samarpan"; /// Replace with Current User in future
    if (update) notifyListeners();
  }

  getUsersVoted() => _usersWhoVoted;
  getCurrentUser() => _currentUser;
  setNewUser(String userName, int choice){
    _usersWhoVoted[userName] = choice;
    notifyListeners();
  }

  _getPollAnswers(pollData) => <String>[
        ...(pollData["answer"].map((ans) => ans.keys.toList()[0].toString()))
      ];

  _getPollAnswersScore(pollData) => <double>[
        ...(pollData["answer"]
            .map((score) => double.parse(score.values.toList()[0])))
      ];

  String getPollQuestion() => _pollData["question"];

  String getIndexedAnswer(int index) => _pollAnswerCollection[index];

  double getIndexedAnswerValue(int index) => _pollAnswerValueCollection[index];

  getTotalAnswer() => _pollAnswerCollection.length;

  increaseIndexedAnswerValue(int index) {
    _pollAnswerValueCollection[index] += 1.0;
    setNewUser(_currentUser!, index+1);
  }

  getPollAnswers() => _pollAnswerCollection;
}
