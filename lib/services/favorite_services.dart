import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//اضافة كارد المعرض الى المفضلة عند تزامن حالة القلب
  Future<void> addToFavorite(String userId, String galleryId) async {
    await _firestore.collection('favorite').add({
      'user_id': userId,
      'gallery_id': galleryId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

//حذف المعرض من المفضلة
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

//جلب كل المفضلة للمستخدم الحالي
  Stream<List<String>> getUserFavorites(String userId) {
    return _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['gallery_id'] as String).toList();
    });
  }

//حذف المفضلة بالكامل
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

// ترجع تدفق يشير إلى ما إذا كان المعرض مفضلًا للمستخدم المحدد.
  Stream<bool> isFavorite(String userId, String galleryId) {
    return _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .where('gallery_id', isEqualTo: galleryId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

// ترجع قيمة تشير إلى ما إذا كان المعرض مفضلًا للمستخدم المحدد.
  Future<bool> isGalleryFavorite(String userId, String galleryId) async {
    final snapshot = await _firestore
        .collection('favorite')
        .where('user_id', isEqualTo: userId)
        .where('gallery_id', isEqualTo: galleryId)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
