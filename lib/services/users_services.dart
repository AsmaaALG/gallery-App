import 'package:cloud_firestore/cloud_firestore.dart';

class UsersServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// انشاء مستخدم جديد داخل كوليكشن users
  Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc();
      await docRef.set({
        'id': docRef.id,
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

// تحسب تقييم المعرض بناءً على عدد النجوم من التعليقات، وترجع متوسط التقييم كقيمة مزدوجة.
  Future<double> calculateRating(String galleryId) async {
    final QuerySnapshot snapshot = await _firestore.collection('reviews').get();

    double totalStars = 0;
    int count = 0;

    for (var doc in snapshot.docs) {
      String currentGalleryId;
      if (doc['gallery id'] is DocumentReference) {
        currentGalleryId = (doc['gallery id'] as DocumentReference).id;
      } else if (doc['gallery id'] is String) {
        currentGalleryId = doc['gallery id'];
      } else {
        continue;
      }

      if (currentGalleryId == galleryId) {
        totalStars += (doc['number of stars'] as num).toDouble();
        count++;
      }
    }

    if (count == 0) return 0.0;
    return ((totalStars / (count * 5)) * 5);
  }

// جلب بيانات المستخدم من كوليكشن users
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return {
          'data': querySnapshot.docs.first.data(),
          'docId': querySnapshot.docs.first.id
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

// تعديل بيانات المستخدم
  Future<void> updateUserData(
      String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(docId).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }
}
