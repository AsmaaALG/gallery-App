import 'dart:async';
import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/screens/signIn_screen.dart';
import 'package:final_project/screens/sign_up_screen.dart';

class SignInUpScreen extends StatefulWidget {
  @override
  _SignInUpScreenState createState() => _SignInUpScreenState();
}

class _SignInUpScreenState extends State<SignInUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/logo.png', // استبدل بمسار الشعار الفعلي
                  height: 170,
                ),
                SizedBox(height: 10),
                Text(
                  "مرحبًا بك في عالم المعارض",
                  style: TextStyle(
                      fontFamily: mainFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // الجزء السفلي ذو التصميم المميز
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "مرحبًا بك في تطبيق معرضي",
                  style: TextStyle(
                    fontFamily: mainFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "يمكنك الآن التسجيل في التطبيق لتتبع كل المعارض التي تثير إعجابك و المعارض التي قمت بزيارتها، مما يتيح لك تجربة مثالية في عالم المعارض",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: mainFont,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                      child: Text("Sign in",
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 40),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SignUpScreen(), // التنقل إلى صفحة التسجيل
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: cardBackground),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                      child: Text("Sign up",
                          style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
