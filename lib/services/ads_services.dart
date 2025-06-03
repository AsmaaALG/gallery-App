import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ad_model.dart';

class AdsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('ads');

//جلب كل الاعلانات من الفايرستور
  Future<List<AdModel>> getAds() async {
    final snapshot = await adsCollection.get();
    return snapshot.docs
        .map((doc) =>
            AdModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

//نقل من كوليكشن الاعلانات لكوليكشن المعارض لما يوصل التاريخ لتاريخ اليوم
  Future<void> moveAdToCollection(
      AdModel ad, String collectionName, String startDate) async {
    if (ad.id.isEmpty) {
      print('معرف الوثيقة غير صالح');
      return;
    }

    DocumentSnapshot snapshot =
        await _firestore.collection('ads').doc(ad.id).get();
    if (!snapshot.exists) {
      print('الوثيقة غير موجودة');
      return;
    }

    // التحقق من وجود المعرض في الكوليكشن 2
    DocumentSnapshot newSnapshot =
        await _firestore.collection(collectionName).doc(ad.id).get();
    if (newSnapshot.exists) {
      print('الإعلان موجود بالفعل في المجموعة $collectionName');
      return;
    }

    try {
      await _firestore.collection(collectionName).doc(ad.id).set({
        'title': ad.title,
        'description': ad.description,
        'start date': startDate,
        'end date': ad.endDate,
        'image url': ad.imageUrl,
        'location': ad.location,
        'QR code': ad.qrCode,
        'phone': ad.phone,
        'classification id': ad.classificationId,
      });

      print('تم نقل الإعلان إلى المجموعة $collectionName بنجاح.');
    } catch (e) {
      print('حدث خطأ أثناء نقل الإعلان: $e');
    }
  }
}
