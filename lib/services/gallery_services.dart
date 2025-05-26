import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gallery_model.dart';
import '../models/category_model.dart';

class GalleryServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// ترجع قائمة المعارض من Firestore.
  Stream<List<GalleryModel>> getItems() {
    return _firestore
        .collection('2')
        .orderBy('end date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GalleryModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

// ترجع قائمة التصنيفات من Firestore.
  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection('classification').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromJson({
          'id': doc.id,
          'name': doc.data()['name'],
        });
      }).toList();
    });
  }

// تتحقق مما إذا كان البريد الإلكتروني موجودًا بالفعل في قاعدة البيانات.
  Future<bool> isEmailAlreadyExists(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}
