import 'package:intl/intl.dart';

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
}
//
// _getFormattedDate(DateTime dateTime){
//   final DateFormat formatter = DateFormat('E');
//   final String formatted = formatter.format(dateTime);
// }
