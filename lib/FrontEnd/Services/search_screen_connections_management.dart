import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:generation/BackendAndDatabaseManager/general_services/notification_configuration.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/connection_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'ChatManagement/ChatScreen.dart';

class Search extends StatefulWidget {
  final SearchType searchType;

  Search({this.searchType = SearchType.ExternalSearch});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final List<String> _allConnectedUserName = [];

  List<Map<String, String>> _userNameProfilePicCollection = [];
  List<Map<String, String>> _selectedUserNameAndProfilePicCollection = [];

  String searchArgument;

  final SendNotification _sendNotification = SendNotification();
  final TextEditingController searchUser = TextEditingController();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  void _internalSearchItems() async {
    if (mounted) {
      setState(() {
        this.isLoading = true;
      });
    }

    await ProfileImageManagement.userProfileNameAndImageExtractor();

    final String _currAccUserName =
        await _localStorageHelper.extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser.email);

    if (mounted) {
      setState(() {
        Map<String, dynamic> tempMap = Map<String, dynamic>();

        tempMap = ProfileImageManagement.allConnectionsProfilePicLocalPath;

        tempMap.forEach((userName, userProfilePicPath) {
          if (userName != _currAccUserName) {
            this._userNameProfilePicCollection.add({
              userName: userProfilePicPath,
            });

            this._selectedUserNameAndProfilePicCollection.add({
              userName: userProfilePicPath,
            });
          }
        });
      });
    }

    if (mounted) {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchArgument = "user_name";
    if (widget.searchType == SearchType.InternalSearch)
      _internalSearchItems();
    else {
      print('Here 1');
      initiateSearch();
    }
  }

  @override
  void dispose() {
    this._userNameProfilePicCollection.clear();
    this._selectedUserNameAndProfilePicCollection.clear();
    super.dispose();
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
            widget.searchType == SearchType.InternalSearch
                ? Container(
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
                            controller: this.searchUser,
                            cursorColor: Colors.white,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText:
                                  "Search by ${this.searchArgument == 'user_name' ? 'User Name' : 'About'}",
                              suffixIcon:
                                  widget.searchType == SearchType.ExternalSearch
                                      ? IconButton(
                                          icon: Icon(Icons.filter_list_rounded),
                                          onPressed: filterOptions,
                                        )
                                      : null,
                              labelStyle: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                              ),
                            ),
                            onChanged: (inputValue) {
                              if (widget.searchType ==
                                  SearchType.ExternalSearch)
                                initiateSearch();
                              else {
                                if (mounted) {
                                  setState(() {
                                    this.isLoading = true;
                                  });
                                }

                                if (mounted) {
                                  setState(() {
                                    this
                                        ._selectedUserNameAndProfilePicCollection
                                        .clear();

                                    this
                                        ._userNameProfilePicCollection
                                        .forEach((userNameMap) {
                                      if (userNameMap.keys.first
                                          .toString()
                                          .toLowerCase()
                                          .startsWith(
                                              '${this.searchUser.text.toLowerCase()}'))
                                        this
                                            ._selectedUserNameAndProfilePicCollection
                                            .add(userNameMap);
                                    });
                                  });
                                }

                                if (mounted) {
                                  setState(() {
                                    this.isLoading = false;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                    child: Text(
                      'Available Connections',
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
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
                : widget.searchType == SearchType.ExternalSearch
                    ? userList()
                    : _internalChatConnectionCollections(),
          ],
        ),
      ),
    );
  }

  Widget _internalChatConnectionCollections() {
    return ModalProgressHUD(
      inAsyncCall: this.isLoading,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: this._selectedUserNameAndProfilePicCollection.length,
          itemBuilder: (context, position) {
            return _logsTile(context, position);
          },
        ),
      ),
    );
  }

  Widget _logsTile(BuildContext context, int index) {
    return Card(
        elevation: 0.0,
        color: Color.fromRGBO(34, 48, 60, 1),
        child: Container(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(34, 48, 60, 1),
              onPrimary: Colors.lightBlueAccent,
              elevation: 0.0,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreenSetUp(
                          this
                              ._selectedUserNameAndProfilePicCollection[index]
                              .keys
                              .first
                              .toString(),
                          this
                              ._selectedUserNameAndProfilePicCollection[index]
                              .values
                              .first
                              .toString())));
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: this
                                ._selectedUserNameAndProfilePicCollection[index]
                                .values
                                .first
                                .toString() ==
                            ''
                        ? ExactAssetImage("assets/logo/logo.jpg")
                        : FileImage(File(this
                            ._selectedUserNameAndProfilePicCollection[index]
                            .values
                            .first
                            .toString())),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: Text(
                      _getUserName(index),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  String _getUserName(int index) => this
              ._selectedUserNameAndProfilePicCollection[index]
              .keys
              .first
              .toString()
              .length <=
          20
      ? this
          ._selectedUserNameAndProfilePicCollection[index]
          .keys
          .first
          .toString()
      : '${this._selectedUserNameAndProfilePicCollection[index].keys.first.toString().replaceRange(20, this._selectedUserNameAndProfilePicCollection[index].keys.first.toString().length, '...')}';

  void _getAllConnectionsFromLocalStorage() async {
    final List<Map<String, Object>> _connectedUsersCollection =
        await _localStorageHelper.extractAllUsersName();

    _connectedUsersCollection.forEach((element) {
      if (mounted) {
        setState(() {
          this._allConnectedUserName.add(element.values.first.toString());
        });
      }
    });
  }

  void initiateSearch() async {
    print('Here 2');

    _getAllConnectionsFromLocalStorage();

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    QuerySnapshot querySnapshot;

    try {
      querySnapshot =
          await FirebaseFirestore.instance.collection('generation_users').get();
    } catch (e) {
      print('Error: ${e.toString()}');
    }

    if (mounted) {
      setState(() {
        this.searchResultSnapshot = querySnapshot;
        isLoading = false;
        haveUserSearched = true;
      });
    }

    print(this.searchResultSnapshot);

    // await FirebaseFirestore.instance
    //     .collection("generation_users")
    //     .where(
    //   searchArgument,
    //
    //   /// We know that, for both ASCII or Unicode, small letters came after capital letters....//So, search query always find the relevant result according to search
    //   isGreaterThanOrEqualTo: searchUser.text.toUpperCase(),
    // )
    //     .get()
    //     .catchError((e) {
    //   print(e.toString());
    // }).then((snapshot) {
    //   searchResultSnapshot = snapshot;
    //
    //   if (mounted) {
    //     setState(() {
    //       isLoading = false;
    //       haveUserSearched = true;
    //     });
    //   }
    // });
  }

  Widget userList() {
    return haveUserSearched
        ? Container(
            height: MediaQuery.of(context).size.height - 80,
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResultSnapshot == null
                    ? 0
                    : searchResultSnapshot.docs.length - 1,
                itemBuilder: (context, index) {
                  print(searchResultSnapshot.docs[index]);
                  if (searchResultSnapshot.docs[index].id ==
                      FirebaseAuth.instance.currentUser.email) {
                    return Center();
                  }
                  return userTile(index);
                }),
          )
        : Container(
            child: Center(
              child: Text(
                "No Matching Found",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          );
  }

  Widget userTile(int index) {
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
                  _encryptionMaker.decryptionMaker(
                      searchResultSnapshot.docs[index][searchArgument]),
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: searchArgument != "about" ? 20 : 15),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  _encryptionMaker.decryptionMaker(
                      searchResultSnapshot.docs[index]
                          [searchArgument == "about" ? "user_name" : "about"]),
                  style: TextStyle(color: Colors.lightBlue, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            child: requestIconController(index),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              side: BorderSide(
                color: _selectColor(index),
              ),
            ),
            onPressed: () async {
              if (mounted) {
                setState(() {
                  isLoading = true;
                });
              }

              DocumentSnapshot documentSnapShotCurrUser =
                  await FirebaseFirestore.instance
                      .collection('generation_users')
                      .doc(FirebaseAuth.instance.currentUser.email)
                      .get();

              Map<String, dynamic> connectionRequestCollectionCurrUser =
                  documentSnapShotCurrUser.get('connection_request');

              Map<String, dynamic> connectionRequestCollectionRequestUser =
                  searchResultSnapshot.docs[index]['connection_request'];

              if (!connectionRequestCollectionCurrUser
                  .containsKey(searchResultSnapshot.docs[index].id)) {
                connectionRequestCollectionCurrUser[
                    searchResultSnapshot.docs[index].id] = "Request Pending";

                connectionRequestCollectionRequestUser[FirebaseAuth
                    .instance.currentUser.email] = "Invitation Came";

                if (mounted) {
                  setState(() {
                    FirebaseFirestore.instance
                        .doc(
                            'generation_users/${searchResultSnapshot.docs[index].id}')
                        .update({
                      'connection_request':
                          connectionRequestCollectionRequestUser,
                    });

                    FirebaseFirestore.instance
                        .doc(
                            'generation_users/${FirebaseAuth.instance.currentUser.email}')
                        .update({
                      'connection_request': connectionRequestCollectionCurrUser,
                    });
                  });
                }

                /// Send Notification About the opponent Person About new notification
                await _sendNotification.sendNotification(
                  token: _encryptionMaker.decryptionMaker(
                      searchResultSnapshot.docs[index]['token']),
                  title: 'New Connection Request',
                  body:
                      '${_encryptionMaker.decryptionMaker(documentSnapShotCurrUser.get('user_name'))} Send You a Connection Request',
                );

                print("Updated");
              } else {
                if (searchResultSnapshot.docs[index]['connection_request']
                        [FirebaseAuth.instance.currentUser.email] ==
                    "Request Pending") {
                  Map<String, dynamic> connectionsMapRequestUser =
                      searchResultSnapshot.docs[index]['connections'];

                  Map<String, dynamic> connectionsMapCurrUser =
                      documentSnapShotCurrUser.get('connections');

                  Map<String, dynamic> activityMapRequestUser =
                      searchResultSnapshot.docs[index]['activity'];
                  Map<String, dynamic> activityMapCurrUser =
                      documentSnapShotCurrUser.get('activity');

                  connectionRequestCollectionCurrUser[searchResultSnapshot
                      .docs[index].id] = "Invitation Accepted";

                  connectionRequestCollectionRequestUser[FirebaseAuth
                      .instance.currentUser.email] = "Request Accepted";
                  print("Add Invited User Data to SQLite");

                  connectionsMapRequestUser[
                      FirebaseAuth.instance.currentUser.email] = [];

                  connectionsMapCurrUser[searchResultSnapshot.docs[index].id] =
                      [];

                  activityMapRequestUser[
                      FirebaseAuth.instance.currentUser.email] = [];

                  activityMapCurrUser[searchResultSnapshot.docs[index].id] = [];

                  if (mounted) {
                    setState(() {
                      print(
                          'Request Connection Request: ${_encryptionMaker.decryptionMaker(searchResultSnapshot.docs[index]['total_connections'])}');

                      FirebaseFirestore.instance
                          .doc(
                              'generation_users/${searchResultSnapshot.docs[index].id}')
                          .update({
                        'connection_request':
                            connectionRequestCollectionRequestUser,
                        'connections': connectionsMapRequestUser,
                        'total_connections': _encryptionMaker.encryptionMaker(
                            '${int.parse(_encryptionMaker.decryptionMaker(searchResultSnapshot.docs[index]['total_connections'])) + 1}'),
                        'activity': activityMapRequestUser,
                      });

                      print(
                          'Current Connection Request: ${_encryptionMaker.decryptionMaker(documentSnapShotCurrUser.get('total_connections'))}');

                      FirebaseFirestore.instance
                          .doc(
                              'generation_users/${FirebaseAuth.instance.currentUser.email}')
                          .update({
                        'connection_request':
                            connectionRequestCollectionCurrUser,
                        'connections': connectionsMapCurrUser,
                        'total_connections': _encryptionMaker.encryptionMaker(
                            '${int.parse(_encryptionMaker.decryptionMaker(documentSnapShotCurrUser.get('total_connections'))) + 1}'),
                        'activity': activityMapCurrUser,
                      });
                    });
                  }

                  /// If Same user Already Present, update their account info
                  if (this._allConnectedUserName.contains(
                      _encryptionMaker.decryptionMaker(
                          searchResultSnapshot.docs[index]['user_name']))) {
                    final QueryDocumentSnapshot queryDocSs =
                        searchResultSnapshot.docs[index];

                    print('Before Updating');

                    await _localStorageHelper.insertOrUpdateDataForThisAccount(
                        userName: _encryptionMaker
                            .decryptionMaker(queryDocSs['user_name']),
                        userMail: queryDocSs.id,
                        userToken: _encryptionMaker
                            .decryptionMaker(queryDocSs['token']),
                        userAbout: _encryptionMaker
                            .decryptionMaker(queryDocSs['about']),
                        userAccCreationDate: _encryptionMaker
                            .decryptionMaker(queryDocSs['creation_date']),
                        userAccCreationTime: _encryptionMaker
                            .decryptionMaker(queryDocSs['creation_time']),
                        purpose: 'update');

                    print('After Updating');
                  }

                  /// Send Notification to Request Sender about Connection Accepted
                  await _sendNotification.sendNotification(
                    token: _encryptionMaker.decryptionMaker(
                        searchResultSnapshot.docs[index]['token']),
                    title: 'Connection Request Accepted',
                    body:
                        '${_encryptionMaker.decryptionMaker(documentSnapShotCurrUser.get('user_name'))} Accept Your Connection Request',
                  );
                } else {
                  print("Nothing To Do");
                }
              }

              if (mounted) {
                setState(() {
                  initiateSearch();
                });
              }

              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void filterOptions() async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
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
                        "User Name",
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            searchArgument = "user_name";
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
                    TextButton(
                      child: Text(
                        "About",
                        style: TextStyle(color: Colors.orange),
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            searchArgument = "about";
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget requestIconController(int index) {
    if (!searchResultSnapshot.docs[index]['connection_request']
        .containsKey('${FirebaseAuth.instance.currentUser.email}')) {
      return Text(
        'Connect',
        style: TextStyle(
          color: Colors.lightBlue,
        ),
      );
    }

    final String oppositeConnectionStatus = searchResultSnapshot.docs[index]
        .data()['connection_request'][FirebaseAuth.instance.currentUser.email];

    final String otherUserName = _encryptionMaker
        .decryptionMaker(searchResultSnapshot.docs[index].data()['user_name']);

    if (oppositeConnectionStatus == 'Invitation Came') {
      return Text(
        'Pending',
        style: TextStyle(
          color: Colors.amber,
        ),
      );
    } else if (oppositeConnectionStatus == 'Request Pending') {
      print("Here Also");
      return Text(
        'Accept',
        style: TextStyle(
          color: Colors.green,
        ),
      );
    } else if ((oppositeConnectionStatus == 'Invitation Accepted' ||
            oppositeConnectionStatus == 'Request Accepted') &&
        this._allConnectedUserName.contains(otherUserName)) {
      print("Here Present");
      return Text(
        'Connected',
        style: TextStyle(
          color: Colors.green,
        ),
      );
    }
    return Text(
      'Connect',
      style: TextStyle(
        color: Colors.lightBlue,
      ),
    );
  }

  Color _selectColor(index) {
    if (!searchResultSnapshot.docs[index]['connection_request']
        .containsKey('${FirebaseAuth.instance.currentUser.email}'))
      return Colors.lightBlue;

    String oppositeConnectionStatus = searchResultSnapshot.docs[index]
        .data()['connection_request'][FirebaseAuth.instance.currentUser.email];

    final String otherUserName = _encryptionMaker
        .decryptionMaker(searchResultSnapshot.docs[index].data()['user_name']);

    if (oppositeConnectionStatus == 'Invitation Came')
      return Colors.amber;
    else if (oppositeConnectionStatus == 'Request Pending')
      return Colors.green;
    else if ((oppositeConnectionStatus == 'Invitation Accepted' ||
            oppositeConnectionStatus == 'Request Accepted') &&
        this._allConnectedUserName.contains(otherUserName)) return Colors.green;

    return Colors.lightBlue;
  }
}
