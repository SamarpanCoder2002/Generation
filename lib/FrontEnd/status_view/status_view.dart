import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

// ignore: must_be_immutable
class StoryView extends StatefulWidget {
  Map<String, dynamic> particularConnectionActivity;

  StoryView({@required this.particularConnectionActivity});

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        color: Color.fromRGBO(0, 0, 0, 0.5),
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black87,
        ),
        child: ListView.builder(
          itemCount: widget.particularConnectionActivity.values.length,
          itemBuilder: (context, index){
            return Container();
          },
        ),
      ),
    );
  }



}
