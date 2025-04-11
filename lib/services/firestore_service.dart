// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gallery_model.dart';
import '../models/category_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة لاسترجاع المعارض
  Stream<List<GalleryModel>> getItems() {
    return _firestore.collection('2').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GalleryModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // دالة لاسترجاع التصنيفات
  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection('classification').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromJson({
          // هنا نستخدم `doc.id` كقيمة لـ id
          'id': doc.id,
          'name': doc.data()[
              'name'], // افترض أن هذا هو اسم الحقل الذي يحتوي على اسم التصنيف
        });
      }).toList();
    });
  }

  // دالة تسجيل الدخول بالاسم وكلمة المرور
  Future<bool> signInWithNameAndPassword(String name, String password) async {
    print("الاسم المدخل: '$name'");
    print("كلمة المرور المدخلة: '$password'");

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('first_name', isEqualTo: name)
          .where('password', isEqualTo: password)
          .get();

      print("عدد النتائج: ${querySnapshot.docs.length}");
      for (var doc in querySnapshot.docs) {
        print("تم العثور على مستخدم: ${doc.data()}");
      }

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("حدث خطأ أثناء تسجيل الدخول: $e");
      return false;
    }
  }

  Future<bool> isEmailAlreadyExists(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

//sign up
  Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc(); // توليد ID تلقائي
      await docRef.set({
        'id': docRef.id, // حفظ الـ ID داخل بيانات المستخدم
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      print("خطأ أثناء إنشاء المستخدم: $e");
      return false;
    }
  }
}
