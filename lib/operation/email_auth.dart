import 'package:firebase_auth/firebase_auth.dart';

class EmailAuth {
  final String email;
  final String pwd;

  EmailAuth({required this.email, required this.pwd});

  Future<bool> signUp() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pwd);
      userCredential.user?.sendEmailVerification();
      return true;
    } catch (e) {
      print("Sign-up Error is: $e");
    }

    return false;
  }

   signIn() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pwd);

      if (!(userCredential.user!.emailVerified)) {
        return "Email Not Verified. Please Check your mail";
      }

      final Map<String,dynamic> _data = {};

      _data["message"] = "Sign In Successful";
      _data["id"] = userCredential.user?.uid ?? "";

      return _data;
    } catch (e) {
      print("Sign Up Error is: $e");
    }

    return "Invalid Email or Password";
  }
}
