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
    scrollController = ScrollController(
      initialScrollOffset: 0.0,
    );

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
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
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
            primary: Color.fromRGBO(25, 39, 52, 1),
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
              color: Colors.green,
            ),
            highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam_rounded,
              color: Colors.redAccent,
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
      margin: EdgeInsets.only(
        top: 20.0,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            //color: Colors.black,
            height: MediaQuery.of(context).size.height - 155,
            padding: EdgeInsets.only(bottom: 10.0, top: 5.0),
            child: Scrollbar(
              showTrackOnHover: false,
              thickness: 4.0,
              child: ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: chatContainer.length,
                itemBuilder: (context, position) {
                  if (position % 2 == 0) return receiverList(context, position);
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
                  onPressed: () {},
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
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        onTap: () {
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent);
                        },
                        controller: inputText,
                        maxLines: null,
                        // For Line Break
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(
                                color: Colors.lightGreen, width: 2.0),
                          ),
                          hintText: 'Type Here',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue)),
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
                    onPressed: () async {
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
              primary: Colors.lightBlue,
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
                color: Colors.white,
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
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }

  Widget receiverList(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width / 3, left: 5.0),
          padding: EdgeInsets.only(top: 5.0),
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(60, 80, 100, 1),
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              chatContainer[index][0],
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {},
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 5.0, bottom: 5.0),
          child: Text(
            chatContainer[index][1],
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }
}
