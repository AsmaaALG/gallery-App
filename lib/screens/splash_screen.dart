import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/mainScreen.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/screens/signInUp_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        // MaterialPageRoute(builder: (_) => SignInUpScreen()),
        MaterialPageRoute(
            builder: (_) =>
                _auth.currentUser != null ? MainScreen() : SignInUpScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // التصميم الجانبي بالأصفر
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 280,
              height: 230,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(190),
                ),
              ),
            ),
          ),

          // ربع دائرة في الزاوية السفلية اليسرى
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(250),
                ),
              ),
            ),
          ),
          // الشعار والنص في المنتصف
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/logo.png', // استبدل بالمسار الصحيح لشعارك
                  width: 200,
                ),
                SizedBox(height: 3),
                Text(
                  'مرحبًا بك في عالم المعارض',
                  style: TextStyle(
                    fontFamily: mainFont,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
