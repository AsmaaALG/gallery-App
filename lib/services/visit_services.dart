import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gallery_model.dart';
import '../models/visit_model.dart';

class VisitServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GalleryModel?> getGalleryById(String galleryId) async {
    try {
      final doc = await _firestore.collection('2').doc(galleryId).get();
      if (doc.exists) {
        return GalleryModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('خطأ في getGalleryById: $e');
      return null;
    }
  }

//  قائمة الزيارات للمستخدم.
  Stream<List<VisitModel>> getUserVisit(String userId) {
    return _firestore
        .collection('visit')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VisitModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

// تسجل زيارة جديدة للمعرض ى.
  Future<void> registerVisitor(
      String userId, String galleryId, DateTime createdAt) async {
    await _firestore.collection('visit').add({
      'userId': userId,
      'galleryId': galleryId,
      'createdAt': createdAt,
    });
  }

// تحقق من وجود تسجيل سابق للزائر
  Future<bool> isVisitorRegistered(String userId, String galleryId) async {
    final snapshot = await _firestore
        .collection('visit')
        .where('userId', isEqualTo: userId)
        .where('galleryId', isEqualTo: galleryId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

// حساب عدد الزوار
  Future<int> getVisitorCount(String galleryId) async {
    final snapshot = await _firestore
        .collection('visit')
        .where('galleryId', isEqualTo: galleryId)
        .get();
    return snapshot.docs.length;
  }

  Future<void> addGalleryToCollection2({
    required String qrCode,
    required String classificationId,
    required String description,
    required String endDate,
    required String imageURL,
    required String location,
    required String phone,
    required String startDate,
    required String title,
  }) async {
    try {
      await _firestore.collection('2').add({
        'QR code': qrCode,
        'classification id': classificationId,
        'description': description,
        'end date': endDate,
        'image url': imageURL,
        'location': location,
        'phone': phone,
        'start date': startDate,
        'title': title,
      });
    } catch (e) {
      throw 'Failed to add gallery to collection 2: $e';
    }
  }
}
