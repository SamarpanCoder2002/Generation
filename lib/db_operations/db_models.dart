import 'package:generation/services/encryption_operations.dart';

class ProfileModel {
  final String name;
  final String about;
  final String email;
  final String profilePic;
  final String token;
  final String id;

  ProfileModel(
      {required this.name,
      required this.about,
      required this.email,
      required this.profilePic,
      required this.token, required this.id});

  static Map<String,dynamic> getJson(
      {required String iName,
      required String iAbout,
      required String iEmail,
      required String iProfilePic,
      required String iToken, required String iId}) {
    final _profile = ProfileModel(
        name: iName,
        about: iAbout,
        email: iEmail,
        profilePic: iProfilePic,
        token: iToken, id: iId);

    return {
      "name": _profile.name,
      "about": _profile.about,
      "email": _profile.email,
      "profilePic": _profile.profilePic,
      "token": _profile.token,
      "createdAt": DateTime.now().toString(),
      "id": _profile.id
    };
  }

  static Map<String,dynamic> getEncodedJson(
      {required String iName,
        required String iAbout,
        required String iEmail,
        required String iProfilePic,
        required String iToken, required String iId}) {
    final _profile = ProfileModel(
        name: iName,
        about: iAbout,
        email: iEmail,
        profilePic: iProfilePic,
        token: iToken, id: iId);

    return {
      "name": Secure.encode(_profile.name),
      "about": Secure.encode(_profile.about),
      "email": Secure.encode(_profile.email),
      "profilePic": Secure.encode(_profile.profilePic),
      "token": Secure.encode(_profile.token),
      "createdAt": Secure.encode(DateTime.now().toString()),
      "id": _profile.id
    };
  }
}
