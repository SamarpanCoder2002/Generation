import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ChatScreenSetUp extends StatefulWidget {
  @override
  _ChatScreenSetUpState createState() => _ChatScreenSetUpState();
}

class _ChatScreenSetUpState extends State<ChatScreenSetUp>
    with TickerProviderStateMixin {
  ScrollController scrollController;
  List chatContainer = [];
  TextEditingController inputText = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ScrollController Initialization
    scrollController = ScrollController(initialScrollOffset: 0.0);

    // For AutoScroll to the end position
    if (scrollController.hasClients)
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    inputText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: true,
        leading: Row(
          children: <Widget>[
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 23.0,
                  backgroundImage: ExactAssetImage(
                    "images/sam.jpg",
                  ),
                ),
                onTap: () {
                  print("Pic Pressed");
                },
              ),
            ),
          ],
        ),
        title: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0.0,
            onSurface: Theme.of(context).primaryColor,
          ),
          child: Text(
            "রাত জাগা তারা",
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          onPressed: () {
            print("Name Clicked");
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.call,
              color: Colors.white,
            ),
            highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam_rounded,
              color: Colors.white,
            ),
            highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
            onPressed: () {},
          ),
        ],
      ),
      body: mainBody(context),
    );
  }

  Widget mainBody(BuildContext context) {
    return Container(
      //color: Colors.lightGreenAccent,
      width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            //color: Colors.black,
            height: MediaQuery.of(context).size.height - 135,
            padding: EdgeInsets.only(bottom: 10.0, top: 5.0),
            child: Scrollbar(
              showTrackOnHover: false,
              thickness: 4.0,
              child: ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: chatContainer.length,
                itemBuilder: (context, position) {
                  return senderList(context, position);
                },
              ),
            ),
          ),
          Container(
            //color: Colors.pinkAccent,
            padding: EdgeInsets.only(bottom: 5.0),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.emoji_emotions_rounded,
                    color: Colors.orangeAccent,
                    size: 30.0,
                  ),
                  onPressed: () {
                  },
                ),
                Container(
                    //color: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.65,
                    //height: 50.0,
                    constraints: BoxConstraints.loose(
                        Size(MediaQuery.of(context).size.width * 0.65, 100.0)),
                    child: Scrollbar(
                      showTrackOnHover: true,
                      thickness: 10.0,
                      radius: Radius.circular(30.0),
                      child: TextField(
                        onTap: () {
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent);
                        },
                        controller: inputText,
                        maxLines: null, // For Line Break
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                                color: Colors.lightGreen, width: 2.0),
                          ),
                          hintText: 'Type Here',
                        ),
                      ),
                    )),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 30.0,
                      color: Colors.brown,
                    ),
                    onPressed: () {
                      print("Options Pressed");
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      size: 30.0,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      print("Send Pressed");
                      if (inputText.text.isNotEmpty) {
                        setState(() {
                          chatContainer.add(
                            [
                              inputText.text,
                              "${DateTime.now().hour}:${DateTime.now().minute}"
                            ],
                          );
                          inputText.clear();
                        });

                        scrollController.jumpTo(
                            scrollController.position.maxScrollExtent + 100);
                        // //Close the keyboard
                        // SystemChannels.textInput.invokeMethod('TextInput.hide');
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 2.0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget senderList(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 3, right: 5.0),
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(100, 100, 250, 0.5),
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              chatContainer[index][0],
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            onPressed: () {},
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
          child: Text(
            chatContainer[index][1],
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
