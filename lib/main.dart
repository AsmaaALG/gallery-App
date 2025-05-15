import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/mainScreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // المستخدم في Flutter يتم تهيئتها قبل بدء التطبيق، وهو أمر ضروري قبل استخدام أي خدمات غير متزامنة مثل Firebase.
  await Firebase.initializeApp(); //تهيئة
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var db = FirebaseFirestore.instance;
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 130, 8, 14)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

