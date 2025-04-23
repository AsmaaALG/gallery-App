// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/gallery_model.dart';
import '../models/category_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//////////////////////////////////////////////////////////////////////////
  ///المفضلـــــــــــة

// دالة لإضافة معرض إلى المفضلة
  Future<void> addToFavorite(String userId, String galleryId) async {
    await _firestore.collection('favorite').add({
      'user_id': userId,
      'gallery_id': galleryId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

// دالة لإزالة معرض من المفضلة
  Future<void> removeFromFavorite(String userId, String galleryId) async {
    final querySnapshot = await _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .where('gallery_id', isEqualTo: galleryId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

// دالة للحصول على قائمة المفضلة للمستخدم
  Stream<List<String>> getUserFavorites(String userId) {
    return _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['gallery_id'] as String).toList();
    });
  }

// دالة لحذف كل المفضلة للمستخدم
  Future<void> clearAllFavorites(String userId) async {
    final querySnapshot = await _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

// دالة للتحقق مما إذا كان المعرض في المفضلة
  Stream<bool> isFavorite(String userId, String galleryId) {
    return _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .where('gallery_id', isEqualTo: galleryId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  //////////////////////////////////////////////////////////////////////////
  ///العلانـــــــات

//////////////////////////////////////////////////////////////////////////
  ///المعــــــــــارض

  // دالة لاسترجاع المعارض
  Stream<List<GalleryModel>> getItems() {
    return _firestore.collection('2').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GalleryModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
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

  // // دالة تسجيل الدخول بالاسم وكلمة المرور
  // Future<bool> signInWithNameAndPassword(String name, String password) async {
  //   print("الاسم المدخل: '$name'");
  //   print("كلمة المرور المدخلة: '$password'");

  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('users')
  //         .where('first_name', isEqualTo: name)
  //         .where('password', isEqualTo: password)
  //         .get();

  //     print("عدد النتائج: ${querySnapshot.docs.length}");
  //     for (var doc in querySnapshot.docs) {
  //       print("تم العثور على مستخدم: ${doc.data()}");
  //     }

  //     if (querySnapshot.docs.isNotEmpty) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     print("حدث خطأ أثناء تسجيل الدخول: $e");
  //     return false;
  //   }
  // }

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

  // Future<double> calculateRating(String galleryId) async {
  //   final QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('reviews')
  //       .where('gallery id', isEqualTo: galleryId)
  //       .get();
  //   print("here id you send ========= $galleryId");
  //   if (snapshot.docs.isEmpty) {
  //     print("No reviews found for gallery ID: $galleryId");

  //     return 0.0;
  //   }

  //   double totalStars = 0;
  //   int count = snapshot.docs.length;

  //   for (var doc in snapshot.docs) {
  //     print("Review stars for document ${doc.id}: ${doc['number of stars']}");
  //     totalStars += doc['number of stars'];
  //   }

  //   print("Total stars: $totalStars, Count: $count");
  //   return (totalStars / count); // قم بإزالة قسم الضرب في 5
  // }

  Future<double> calculateRating(String galleryId) async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('reviews').get();

    double totalStars = 0;
    int count = 0;

    for (var doc in snapshot.docs) {
      // التحقق من نوع gallery id
      String currentGalleryId;
      if (doc['gallery id'] is DocumentReference) {
        DocumentReference galleryRef = doc['gallery id'];
        currentGalleryId = galleryRef.id; // استخرج المعرف
      } else if (doc['gallery id'] is String) {
        currentGalleryId = doc['gallery id'];
      } else {
        continue; // تخطي المستندات التي لا تحتوي على gallery id صالح
      }

      // تحقق مما إذا كان المعرف يطابق المعرف المدخل
      if (currentGalleryId == galleryId) {
        double stars = (doc['number of stars'] as num).toDouble();
        totalStars += stars;
        count++;
      }
    }

    if (count == 0) {
      print("No reviews found for gallery ID: $galleryId");
      return 0.0;
    }

    return (totalStars / (count * 5)) * 5;
  }
}
