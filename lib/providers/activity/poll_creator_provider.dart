import 'package:flutter/material.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';

class PollCreatorProvider extends ChangeNotifier {
  final TextEditingController _questionController = TextEditingController();

  var _answerControllerCollection =
      List.generate(2, (index) => TextEditingController());

  addNewAnswerController() {
    _answerControllerCollection.add(TextEditingController());
    notifyListeners();
  }

  deleteLastAnswerController(BuildContext context) {
    if (_answerControllerCollection.length <= 2) {
      showToast(context,
          title: "Answer Must Have Two Options",
          toastIconType: ToastIconType.warning);
      return;
    }

    _answerControllerCollection.removeLast();
    notifyListeners();
  }

  getQuestionController() => _questionController;

  getAllAnswerController() => _answerControllerCollection;

  reset(){
    _questionController.clear();
    _answerControllerCollection.clear();
    _answerControllerCollection =
        List.generate(2, (index) => TextEditingController());
    notifyListeners();
  }
}
