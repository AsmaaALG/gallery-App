import 'package:final_project/services/auth.dart';
import 'package:final_project/services/gallery_services.dart';
import 'package:final_project/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/custom_text_field.dart';
import 'mainScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showSpinner = false;
  Future<void> _signUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    bool created = false;
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }
    setState(() {
      showSpinner = true;
    });
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('كلمة المرور يجب ان تحتوي على 6 ارقام او حروف على الاقل')),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('البريد الإلكتروني غير صالح')),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }

    bool emailExists = await GalleryServices().isEmailAlreadyExists(email);
    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('البريد الإلكتروني مستخدم مسبقًا')),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    } else {
      created = await UsersServices().createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      Auth().signUp(emailController, passwordController);
    }
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(primaryColor), // تغيير اللون هنا
        ),
        child: Column(
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
                          "إنشاء الحساب",
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
      ),
    );
  }
}
