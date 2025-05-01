import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id; // معرف المراجعة
  final String galleryId; // معرف المعرض المرتبط
  final double rating; // عدد النجوم
  final String userId; // معرف المستخدم
  final DateTime date; // تاريخ المراجعة
  final String comment;
  String userName;

  Review({
    required this.id,
    required this.galleryId,
    required this.rating,
    required this.userId,
    required this.date,
    required this.comment,
    required this.userName,
  });

  // دالة لتحويل البيانات من JSON إلى كائن Review
  factory Review.fromJson(Map<String, dynamic> json, String id) {
    return Review(
      id: id,
      comment: json['comment'] ?? '',
      galleryId: json['gallery id'] ?? '',
      rating: (json['number of stars'] as num).toDouble(),
      userId: json['user id'] ?? '',
      date: DateTime.parse(
          json['date'] ?? DateTime.now().toIso8601String()), // تعديل هنا
      userName: '',
    );
  }

  // دالة لتحويل كائن Review إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'gallery id': galleryId,
      'number of stars': rating,
      'user id': userId,
      'comment': comment,
      // 'date': date.toIso8601String(),
    };
  }
}
