import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:final_project/screens/notifications_screen.dart';
import 'package:final_project/screens/splash_screen.dart';
import 'package:flutter/services.dart'; // تم إضافته لإيقاف التدوير

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// إشعار محلي
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// معالجة الإشعار في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _saveNotificationToFirestore(message);
}

/// حفظ الإشعار في Firestore
Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
  final title = message.notification?.title ?? 'بدون عنوان';
  final body = message.notification?.body ?? 'لا يوجد محتوى';

  await FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'body': body,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// تهيئة الإشعارات المحلية
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

/// عرض إشعار محلي
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

  // لمنع التدوير وجعل التطبيق فقط في الوضع العمودي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(); // تهيئة Firebase
  // إشترك في topic لاستقبال الإشعارات الجماعية
  await FirebaseMessaging.instance.subscribeToTopic("allUsers");

  // طباعة التوكن (يمكن نسخه لاستخدامه في إرسال الإشعار من Firebase Console)
  FirebaseMessaging.instance.getToken().then((token) {
    print(" FCM Token: $token");
  });

  // تهيئة الإشعارات المحلية
  await initializeLocalNotifications();

  // المعالج في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // الإشعار أثناء فتح التطبيق
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await _saveNotificationToFirestore(message);
    await showLocalNotification(message);
  });

  // عند فتح التطبيق من الإشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => NotificationsScreen()),
    );
  });

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
