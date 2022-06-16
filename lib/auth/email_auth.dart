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
      debug("Sign-up Error is: $e");
    }

    return false;
  }

  Future<Map<String, dynamic>> signIn() async {
    final Map<String, dynamic> _data = {};

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pwd);

      if (!(userCredential.user!.emailVerified)) {
        _data["success"] = false;
        _data["message"] = "Email Not Verified. Please Check your mail";
        return _data;
      }

      _data["success"] = true;
      _data["message"] = "Sign In Successful";
      _data["id"] = userCredential.user?.uid ?? "";

      return _data;
    } catch (e) {
      debug("Sign Up Error is: $e");
    }

    _data["success"] = false;
    _data["message"] = "Invalid Email or Password";
    return _data;
  }
}
