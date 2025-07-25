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
                  'images/logo.png',
                  height: 170,
                ),
                SizedBox(height: 10),
                Text(
                  "مرحبًا بك في عالم المعارض",
                  style: TextStyle(
                    fontFamily: mainFont,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "مرحبًا بك في تطبيق معرضي",
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 16,
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
                          fontSize: 13,
                          color: Colors.black87),
                    ),
                  ],
                ),

                // SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text("تسجيل الدخول",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: mainFont,
                              fontSize: 12)),
                    ),
                    // SizedBox(width: 40),
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
                            EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: Text("إنشاء حساب جديد",
                          style: TextStyle(
                              color: primaryColor,
                              fontFamily: mainFont,
                              fontSize: 12)),
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
