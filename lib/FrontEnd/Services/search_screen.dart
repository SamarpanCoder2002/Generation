import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Icon _iconSample = Icon(Icons.filter_list_rounded);
  String searchArgument;

  TextEditingController searchUser = TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchUser.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection("generation_users")
          .where(
            searchArgument,
            isGreaterThanOrEqualTo: searchUser.text
                .toUpperCase(), // We know that, for both ASCII or Unicode, small letters came after capital letters....//So, search query always find the relevant result according to search
          )
          .get()
          .catchError((e) {
        print(e.toString());
      }).then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              print(searchResultSnapshot.docs[index]);
              return userTile(
                searchResultSnapshot.docs[index][searchArgument],
                searchResultSnapshot.docs[index]
                    [searchArgument == "about" ? "nick_name" : "about"],
              );
            })
        : Container(
            child: Center(
              child: Text(
                "No Matching Found",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          );
  }

  Widget userTile(String userName, String userAbout) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: searchArgument != "about" ? 20 : 15),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  userAbout,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.person_add_alt_1_outlined,
              size: 30.0,
              color: Colors.green,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchArgument = "nick_name";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        //color: Colors.black87,
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 5,
                bottom: 10,
              ),
              margin: EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(25, 39, 52, 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: searchUser,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "Enter Username",
                        suffixIcon: IconButton(
                          icon: _iconSample,
                          onPressed: filterOptions,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontFamily: 'Lora',
                          letterSpacing: 1.0,
                        ),
                      ),
                      onChanged: (inputValue) {
                        initiateSearch();
                      },
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  )
                : userList(),
          ],
        ),
      ),
    );
  }

  void filterOptions() async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Color.fromRGBO(34, 48, 60, 1),
              shape: CircleBorder(),
              title: Center(
                child: Text(
                  "Filter",
                  style: TextStyle(
                      color: Colors.lightGreen,
                      letterSpacing: 1.0,
                      fontSize: 23.0,
                      fontFamily: 'Lora'),
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        "Nick Name",
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () {
                        setState(() {
                          searchArgument = "nick_name";
                          Navigator.pop(context);
                        });
                      },
                    ),
                    TextButton(
                      child: Text(
                        "User Name",
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () {
                        setState(() {
                          searchArgument = "user_name";
                          Navigator.pop(context);
                        });
                      },
                    ),
                    TextButton(
                      child: Text(
                        "About",
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () {
                        setState(() {
                          searchArgument = "about";
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ));
  }
}
