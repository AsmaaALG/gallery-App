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
  
}
