import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/custom_text_field.dart';
import 'package:final_project/widgets/social_button.dart';
import '../services/firestore_service.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/sign_up_screen.dart';
import 'package:final_project/screens/mainScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // دالة تسجيل الدخول
  Future<void> _signIn() async {
    final name = nameController.text.trim();
    final pass = passwordController.text.trim();

    if (name.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال الاسم وكلمة المرور')),
      );
      return;
    }

    bool isValid =
        await FirestoreService().signInWithNameAndPassword(name, pass);

    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الاسم أو كلمة المرور غير صحيحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC40),
      body: Column(
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    hintText: "اسم المستخدم",
                    controller: nameController,
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
                      "Sign in",
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
                        style: TextStyle(fontFamily: mainFont, fontSize: 14),
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
                  Expanded(
                    child: SocialButton(
                      icon: FontAwesomeIcons.google,
                      text: "continue with google",
                      color: cardBackground,
                      textColor: Colors.black,
                      iconColor: primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SocialButton(
                      icon: FontAwesomeIcons.facebook,
                      text: "continue with facebook",
                      color: cardBackground,
                      textColor: Colors.black,
                      iconColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
