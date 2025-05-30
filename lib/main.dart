import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'; // تم إضافته لإيقاف التدوير

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // لمنع التدوير وجعل التطبيق فقط في الوضع العمودي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(); // تهيئة Firebase

  runApp(MyApp());
}

// ignore: must_be_immutable
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
