import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  Future<bool> signIn(emailController, passwordController) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }


  Future<UserCredential?> signUp(
  TextEditingController emailController,
  TextEditingController passwordController,
) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    return userCredential;
  } catch (e) {
    print("خطأ أثناء التسجيل: $e");
    return null;
  }
}


  Future<void> signOut(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null; // المستخدم ألغى العملية

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("خطأ في تسجيل الدخول بجوجل: $e");
      return null;
    }
  }
}
