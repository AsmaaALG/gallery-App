import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ad_model.dart';

class AdsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('ads');

  Future<List<AdModel>> getAds() async {
    final snapshot = await adsCollection.get();
    return snapshot.docs
        .map((doc) =>
            AdModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

// //نقل من كوليكشن الاعلانات لكوليكشن المعارض لما يوصل التاريخ لتاريخ اليوم
//   Future<void> moveAdToCollection(
//       AdModel ad, String collectionName, String startDate) async {
//     if (ad.id.isEmpty) {
//       print('معرف الوثيقة غير صالح');
//       return;
//     }

//     DocumentSnapshot snapshot =
//         await _firestore.collection('ads').doc(ad.id).get();
//     if (!snapshot.exists) {
//       print('الوثيقة غير موجودة');
//       return;
//     }

//     // التحقق من وجود المعرض في الكوليكشن 2
//     DocumentSnapshot newSnapshot =
//         await _firestore.collection(collectionName).doc(ad.id).get();
//     if (newSnapshot.exists) {
//       print('الإعلان موجود بالفعل في المجموعة $collectionName');
//       return;
//     }

//     try {
//       await _firestore.collection(collectionName).doc(ad.id).set(ad.toMap());


//       print('تم نقل الإعلان إلى المجموعة $collectionName بنجاح.');
//     } catch (e) {
//       print('حدث خطأ أثناء نقل الإعلان: $e');
//     }
//   }

  
//   Future<void> deleteExpiredAds() async {
//     try {
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);

//       final snapshot = await adsCollection.get();

//       for (final doc in snapshot.docs) {
//         final ad = AdModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//         final stopAdDate = _parseDate(ad.stopAd);

//         if (stopAdDate.isBefore(today) || stopAdDate.isAtSameMomentAs(today)) {
//           await adsCollection.doc(ad.id).delete();
//           print('تم حذف الإعلان المنتهي (ID: ${ad.id})');
//         }
//       }
//     } catch (e) {
//       print('حدث خطأ أثناء حذف الإعلانات المنتهية: $e');
//     }
//   }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? DateTime.now().year;
    return DateTime(year, month, day);
  }
}
