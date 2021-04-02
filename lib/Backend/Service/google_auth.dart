import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> logIn() async {
    try {
      if (!await googleSignIn.isSignedIn()) {
        final user = await googleSignIn.signIn();
        if (user == null)
          print("Already Signed In");
        else {
          final GoogleSignInAuthentication googleAuth =
              await user.authentication;

          final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

          print("Log-In Successful: User Name: ${userCredential.user.email}");
          print(userCredential.additionalUserInfo);
        }
        return true;
      } else {
        print("Already Logged In");
        return true;
      }
    } catch (e) {
      print("Google LogIn Error: ${e.toString()}");
      return false;
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
