import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile"
  ]);

  logIn() async {
    try {
      if (!await googleSignIn.isSignedIn()) {
        final user = await googleSignIn.signIn();
        if (user == null) {
          print("Google Sign In Not Completed");
        } else {
          final GoogleSignInAuthentication googleAuth =
              await user.authentication;

          final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

          final _userData = userCredential.user;

          final Map<String,dynamic> _userCollectedData = {};

          _userCollectedData["name"] = _userData?.displayName ?? "";
          _userCollectedData["email"] = _userData?.email ?? "";
          _userCollectedData["profilePic"] = _userData?.photoURL ?? "";
          _userCollectedData["id"] = _userData?.uid ?? "";

          print("User Data: $_userData");

          return _userCollectedData;
        }
      } else {
        print("Already Logged In");
        await logOut();
        return await logIn();
      }
    } catch (e) {
      print("Google LogIn Error: ${e.toString()}");
      return null;
    }
  }

  Future<bool> logOut() async {
    try {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
