import 'package:final_project/services/auth.dart';
import 'package:final_project/services/users_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/custom_text_field.dart';
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

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$");
    final allowedDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com'
    ];
    if (!regex.hasMatch(email)) return false;
    final domain = email.split('@').last.toLowerCase();
    return allowedDomains.contains(domain);
  }

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
        SnackBar(
            content: Text(textAlign: TextAlign.right, 'يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() {
      showSpinner = true;
    });

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            textAlign: TextAlign.right,
            'كلمة المرور يجب ان تحتوي على 6 ارقام او حروف على الاقل',
          ),
        ),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(textAlign: TextAlign.right, 'البريد الإلكتروني غير صالح')),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }

    final emailUsed = await Auth().isEmailTaken(email);
    if (emailUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                textAlign: TextAlign.right,
                'هذا البريد الإلكتروني مستخدم مسبقًا')),
      );
      setState(() {
        showSpinner = false;
      });
      return;
    }

    try {
      final userCredential =
          await Auth().signUp(emailController, passwordController);

      if (userCredential != null) {
        await Auth().signIn(emailController, passwordController);
        created = await UsersServices().createUser(
          uid: userCredential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء إنشاء الحساب';
      if (e.code == 'network-request-failed') {
        errorMessage = 'لا يوجد اتصال بالإنترنت';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صالح';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'البريد الإلكتروني مستخدم مسبقًا';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textAlign: TextAlign.right, errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(textAlign: TextAlign.right, 'لا يوجد اتصال بالإنترنت')),
      );
    } finally {
      setState(() {
        showSpinner = false;
      });
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
              AlwaysStoppedAnimation<Color>(primaryColor),
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
                fontSize: 18,
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
                              fontSize: 14),
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
