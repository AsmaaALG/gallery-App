import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/signInUp_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/custom_text_field.dart';
import 'package:final_project/widgets/social_button.dart';
import 'package:final_project/screens/sign_up_screen.dart';
import 'package:final_project/screens/mainScreen.dart';
import 'package:final_project/services/auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showSpinner = false;

  Future<void> _signIn() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    setState(() {
      showSpinner = true;
    });

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textAlign: TextAlign.right,
            'يرجى إدخال البريد الإلكتروني وكلمة المرور',
          ),
        ),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }

    try {
      bool isValid = await Auth().signIn(emailController, passwordController);

      if (isValid) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                textAlign: TextAlign.right,
                'البريد الإلكتروني غير صحيح',
              ),
            ),
          );
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.right,
              'البريد الإلكتروني أو كلمة المرور غير صحيحة',
            ),
          ),
        );
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textAlign: TextAlign.right,
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة لاحقًا.',
          ),
        ),
      );
    } catch (e) {
      final errorText = e.toString().toLowerCase();

      if (errorText.contains('network') ||
          errorText.contains('internet') ||
          errorText.contains('unavailable') ||
          errorText.contains('socket')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.right,
              'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة لاحقًا.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.right,
              'حدث خطأ أثناء تسجيل الدخول: $e',
            ),
          ),
        );
      }
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  /////////
  Future<void> _signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final userCredential = await Auth().signInWithGoogle();

      if (userCredential != null) {
        final User user = userCredential.user!;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'first_name': user.displayName?.split(' ').first ?? '',
            'last_name': user.displayName?.split(' ').length == 2
                ? user.displayName!.split(' ').last
                : '',
            'email': user.email ?? '',
          });
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  textAlign: TextAlign.right,
                  'فشل تسجيل الدخول باستخدام جوجل')),
        );
      }
    } catch (e) {
      print("خطأ في تسجيل الدخول باستخدام جوجل: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                textAlign: TextAlign.right, 'حدث خطأ أثناء تسجيل الدخول: $e')),
      );
    }
  }

  ///

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC40),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInUpScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  "مرحبًا بك مجددًا",
                  style: TextStyle(
                    fontFamily: mainFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "يمكنك التسجيل في التطبيق عبر تسجيل الدخول\nاو عن طريق حساب قوقل ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: mainFont, fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 80),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        hintText: "البريد الإلكتروني",
                        controller: emailController,
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        hintText: "كلمة المرور",
                        obscureText: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "التسجيل",
                          style: TextStyle(
                              fontFamily: mainFont,
                              color: cardBackground,
                              fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            "ليس لديك حساب؟ ",
                            style:
                                TextStyle(fontFamily: mainFont, fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpScreen()),
                              );
                            },
                            child: Text(
                              "سجل من هنا",
                              style: TextStyle(
                                fontFamily: mainFont,
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(thickness: 1, color: Colors.grey[400]),
                      SizedBox(height: 10),
                      SocialButton(
                        icon: FontAwesomeIcons.google,
                        text: "التسجيل باستخدام جوجل",
                        color: cardBackground,
                        textColor: Colors.black,
                        iconColor: primaryColor,
                        onPressed: _signInWithGoogle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
