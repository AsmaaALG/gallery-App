import 'package:cloud_firestore/cloud_firestore.dart';

class VisitModel {
  final String id; 
  final String galleryId;
  final String userId;
  final DateTime createdAt;

  VisitModel({
    required this.id,
    required this.galleryId,
    required this.userId,
    required this.createdAt,
  });


  factory VisitModel.fromJson(Map<String, dynamic> json, String id) {
    return VisitModel(
      id: id,
      galleryId: json['galleryId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'galleryId': galleryId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(), 
    };
  }
}
