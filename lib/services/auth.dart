import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<bool> signUp(emailController, passwordController) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      return true; // إذا تم تسجيل الحساب بنجاح
    } catch (e) {
      print(e); // طباعة الخطأ في وحدة التحكم
      return false; // إعادة false في حالة حدوث خطأ
    }
  }
   Future<void> signOut(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
    );
  }
}
