import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/custom_text_field.dart';
import 'package:final_project/widgets/social_button.dart';
import 'package:final_project/screens/sign_up_screen.dart';
import 'package:final_project/screens/mainScreen.dart';
import 'package:final_project/services/auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:google_sign_in/google_sign_in.dart'; //
import 'package:firebase_auth/firebase_auth.dart'; //

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showSpinner = false;

  // دالة تسجيل الدخول
  Future<void> _signIn() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    setState(() {
      showSpinner = true;
    });

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور')),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }

    // محاولة تسجيل الدخول
    bool isValid = await Auth().signIn(emailController, passwordController);

    if (isValid) {
      // تحقق من وجود المستخدم في جدول user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email',
              isEqualTo: email) // نفترض أن هناك حقل 'email' في المستندات
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('البريد الإلكتروني ليس مسجلاً كمسؤول')),
        );
        setState(() {
          showSpinner = false;
        });
        return;
      }

      // إذا كان كل شيء صحيح، انتقل إلى MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة')),
      );
    }

    setState(() {
      showSpinner = false;
    });
  }

  /////////
  Future<void> _signInWithGoogle() async {
    try {
      // ✅ تسجيل الخروج من أي جلسة سابقة
      await GoogleSignIn().signOut();
      final userCredential = await Auth().signInWithGoogle();

      if (userCredential != null) {
        final User user = userCredential.user!;

        // تحقق هل المستخدم محفوظ مسبقاً في Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // إذا لم يكن محفوظ، نضيفه
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

        //  الانتقال للصفحة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الدخول باستخدام جوجل')),
        );
      }
    } catch (e) {
      print("خطأ في تسجيل الدخول باستخدام جوجل: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول: $e')),
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
          valueColor:
              AlwaysStoppedAnimation<Color>(primaryColor), // تغيير اللون هنا
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
                      Navigator.pop(context);
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "يمكنك التسجيل في التطبيق عبر تسجيل الدخول\nاو عن طريق حساب قوقل او حساب فيسبوك",
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "هل نسيت كلمة المرور؟",
                            style: TextStyle(
                                fontFamily: mainFont,
                                color: primaryColor,
                                fontSize: 14),
                          ),
                        ),
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
                              fontSize: 18),
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
                                TextStyle(fontFamily: mainFont, fontSize: 14),
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
                                fontSize: 14,
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
