import 'dart:async';
import 'package:flutter/material.dart';
import 'package:final_project/screens/mainScreen.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/screens/signInUp_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SignInUpScreen()),
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
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(190),
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
                  width: 170,
                ),
                SizedBox(height: 10),
                Text(
                  'مرحبًا بك في عالم المعارض',
                  style: TextStyle(
                    fontFamily: mainFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
