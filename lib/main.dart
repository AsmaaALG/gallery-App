import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:final_project/screens/notifications_screen.dart';
import 'package:final_project/screens/splash_screen.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _saveNotificationToFirestore(message);
}

Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
  final title = message.notification?.title ?? 'بدون عنوان';
  final body = message.notification?.body ?? 'لا يوجد محتوى';

  await FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'body': body,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => NotificationsScreen()),
      );
    },
  );
}

Future<void> showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel', // يجب أن يتطابق مع ما حددته في Firebase Console
    'الإشعارات',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'بدون عنوان',
    message.notification?.body ?? 'لا يوجد محتوى',
    platformDetails,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  bool firebaseInitialized = false;

  try {
    await Firebase.initializeApp(); // محاولة التهيئة
    firebaseInitialized = true;
  } catch (e) {
    print("خطأ أثناء تهيئة Firebase: $e");
  }

  if (firebaseInitialized) {
    try {
      await FirebaseMessaging.instance.subscribeToTopic("allUsers");

      FirebaseMessaging.instance.getToken().then((token) {
        print("FCM Token: $token");
      });

      await initializeLocalNotifications();

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await _saveNotificationToFirestore(message);
        await showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => NotificationsScreen()),
        );
      });
    } catch (e) {
      print("خطأ أثناء تهيئة خدمات الإشعارات: $e");
    }
  }

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
