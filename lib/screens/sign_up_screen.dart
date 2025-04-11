import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/custom_text_field.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';
import 'mainScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('البريد الإلكتروني غير صالح')),
      );
      return;
    }

    bool exists = await FirestoreService().isEmailAlreadyExists(email);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('البريد الإلكتروني مستخدم مسبقًا')),
      );
      return;
    }

    bool created = await FirestoreService().createUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (created) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إنشاء الحساب')),
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
            "إنشاء حساب جديد",
            style: TextStyle(
              fontFamily: mainFont,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "يرجى ملء البيانات لإنشاء حساب جديد",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: mainFont, fontSize: 14, color: Colors.black),
          ),
          SizedBox(height: 50),
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
                      hintText: "الاسم الأول",
                      controller: firstNameController,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: "اسم العائلة",
                      controller: lastNameController,
                    ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontFamily: mainFont,
                            color: cardBackground,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
