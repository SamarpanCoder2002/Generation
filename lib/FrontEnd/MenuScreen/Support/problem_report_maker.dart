import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:url_launcher/url_launcher.dart';

class ProblemMaker extends StatefulWidget {
  const ProblemMaker({Key key}) : super(key: key);

  @override
  _ProblemMakerState createState() => _ProblemMakerState();
}

class _ProblemMakerState extends State<ProblemMaker> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final TextEditingController _problemTitleController = TextEditingController();
  final TextEditingController _problemDescriptionController =
      TextEditingController();

  @override
  void initState() {
    this._problemTitleController.text = '';
    this._problemDescriptionController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    this._problemTitleController.dispose();
    this._problemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        title: Text(
          'Describe Your Problem',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(
          20.0,
        ),
        child: Form(
          key: _globalKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width - 40,
                child: TextFormField(
                  controller: this._problemTitleController,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  validator: (inputValue) {
                    if (inputValue.length == 0)
                      return 'Please Provide a Problem Title';
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Problem Title',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Lora',
                        letterSpacing: 1.0,
                      ),
                      suffixIcon: Icon(
                        Icons.report_problem_outlined,
                        color: Colors.red,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.green,
                      ))),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width - 40,
                child: TextFormField(
                  maxLines: null,
                  controller: this._problemDescriptionController,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  validator: (inputValue) {
                    if (inputValue.length == 0)
                      return 'Please Provide a Problem Description';
                    return null;
                  },
                  decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.description_outlined,
                        color: Colors.green,
                      ),
                      labelText: 'Problem Description',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Lora',
                        letterSpacing: 1.0,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.green,
                      ))),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: 30.0,
                  bottom: 20.0,
                ),
                child: TextButton(
                  child: Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18.0,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    side: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () async {
                    if (_globalKey.currentState.validate()) {
                      final Uri params = Uri(
                        scheme: 'mailto',
                        path: 'generationofficialteam@gmail.com',
                        query:
                            'subject=Generation Problem: ${this._problemTitleController.text} &body=${this._problemDescriptionController.text}', //add subject and body here
                      );

                      final String url = params.toString();
                      try {
                        await launch(url);
                      } catch (e) {
                        print('Mail Sending Error: ${e.toString()}');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
