import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/reviews_model.dart';
import 'package:final_project/models/suite_image_model.dart';
import 'package:final_project/models/suite_model.dart';
import 'package:final_project/models/users_model.dart';
import '../models/partner_model.dart';

class SuiteServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// جلب كل الاجنحة الخاصة بالمعرض المحدد
  Future<List<SuiteModel>> getSuites(String galleryId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('suite')
          .where('gallery id', isEqualTo: galleryId)
          .get();
      return snapshot.docs.map((doc) {
        return SuiteModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching suites: $e');
      return [];
    }
  }

// جلب جميع التقييمات الخاصة بالمعرض المحدد
  Future<List<ReviewsModel>> getReviews(String galleryId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('reviews')
        .where('gallery id', isEqualTo: galleryId)
        .get();

    List<ReviewsModel> reviews = snapshot.docs
        .map((doc) =>
            ReviewsModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    reviews = reviews.where((review) => review.comment.isNotEmpty).toList();

    for (var review in reviews) {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('userId', isEqualTo: review.userId)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        UsersModel user =
            UsersModel.fromJson(userDoc.data() as Map<String, dynamic>);
        review.userName = '${user.firstName} ${user.lastName}';
      } else {
        review.userName = "Unknown User";
      }
    }

    return reviews;
  }

// جلب كل الشركاء الخاصين بالمعرض المحدد
  Future<List<PartnerModel>> getPartners(String galleryId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('partners')
        .where('gallery id', isEqualTo: galleryId)
        .get();
    return snapshot.docs.map((doc) {
      return PartnerModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

// جلب جميع الصور الخاصة بالجناح المحدد
  Future<List<SuiteImageModel>> getSuiteImages(String suiteId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('suite image')
        .where('suite id', isEqualTo: suiteId)
        .get();
    return snapshot.docs.map((doc) {
      return SuiteImageModel.fromJson(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
