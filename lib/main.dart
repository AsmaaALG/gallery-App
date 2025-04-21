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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

// class PostCard extends StatelessWidget {
//   final String title;
//   final String content;

//   const PostCard({Key? key, required this.title, required this.content})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(10),
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10), // Space between title and content
//             Text(
//               content,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
