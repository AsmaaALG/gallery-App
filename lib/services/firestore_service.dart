import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/ad_model.dart';
import 'package:final_project/models/partner.dart';
import 'package:final_project/models/reviews.dart';
import 'package:final_project/models/suite.dart';
import 'package:final_project/models/suite_image.dart';
import 'package:final_project/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<bool> isGalleryFavorite(String userId, String galleryId) async {
    final snapshot = await _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .where('gallery_id', isEqualTo: galleryId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  //////////////////////////////////////////////////////////////////////////
  ///العلانـــــــات

  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('ads');

  Future<List<AdModel>> getAds() async {
    final snapshot = await adsCollection.get();
    return snapshot.docs
        .map((doc) => AdModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

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

    return ((totalStars / (count * 5)) * 5);
  }
  ////////////////////////////////////////////////////////////////////////////
  ///الاجنحة

  // دالة لجلب الأجنحة المرتبطة بمعرض معين
  Future<List<Suite>> getSuites(String galleryId) async {
    try {
      // استعلام لجلب الأجنحة التي تتطابق مع galleryId
      QuerySnapshot snapshot = await _firestore
          .collection('suite') // اسم مجموعة الأجنحة
          .where('gallery id', isEqualTo: galleryId) // الشرط للبحث
          .get();
      // تحويل مستندات Firestore إلى قائمة من كائنات Suite
      return snapshot.docs.map((doc) {
        return Suite.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching suites: $e');
      return []; // في حال حدوث خطأ، إرجاع قائمة فارغة
    }
  }

  Future<List<Review>> getReviews(String galleryId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('reviews')
        .where('gallery id', isEqualTo: galleryId)
        .get();

    List<Review> reviews = snapshot.docs
        .map((doc) =>
            Review.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    for (var review in reviews) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(review.userId).get();
      Users user =
          Users.fromJson(userDoc.data() as Map<String, dynamic>, userDoc.id);
      review.userName =
          '${user.firstName} ${user.lastName}'; // تكوين الاسم الكامل
      print("name::::::: ${review.userName} comment ${review.comment}");
    }

    return reviews;
  }

  Future<List<Partner>> getPartners(String galleryId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('partners')
        .where('gallery id',
            isEqualTo: galleryId) // تصفية الشركاء حسب معرف المعرض
        .get();
    return snapshot.docs.map((doc) {
      return Partner.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  /////////////image
  Future<List<SuiteImage>> getSuiteImages(String suiteId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('suite image')
        .where('suite id', isEqualTo: suiteId)
        .get();
    print("number:::::::::: ${snapshot.size}");

    return snapshot.docs.map((doc) {
      return SuiteImage.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
