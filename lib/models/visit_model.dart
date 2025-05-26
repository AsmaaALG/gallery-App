import 'package:cloud_firestore/cloud_firestore.dart';

class VisitModel {
  final String id; // ID حق الزيارة نفسها
  final String galleryId;
  final String userId;
  final DateTime createdAt; // الحقل المضاف

  VisitModel({
    required this.id,
    required this.galleryId,
    required this.userId,
    required this.createdAt,
  });

  // Factory method: fromJson
  factory VisitModel.fromJson(Map<String, dynamic> json, String id) {
    return VisitModel(
      id: id,
      galleryId: json['galleryId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // استخدام الوقت الحالي في حال عدم وجود قيمة
    );
  }

  // To JSON method (لو تحتاج تضيف زيارة)
  Map<String, dynamic> toJson() {
    return {
      'galleryId': galleryId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(), // تحويل التاريخ لسلسلة نصية
    };
  }
}
