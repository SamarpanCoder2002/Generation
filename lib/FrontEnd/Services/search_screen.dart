import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
          .where("user_name", isEqualTo: searchUser.text)
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
              return userTile(
                searchResultSnapshot.docs[index]["user_name"],
                searchResultSnapshot.docs[index].id,
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

  Widget userTile(String userName, String userEmail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        //color: Colors.black87,
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 25,
                bottom: 5,
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
}
