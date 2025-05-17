import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryModel {
  final String qrCode;
  final String classificationId; // إضافة classificationId هنا
  final String imageURL;
  final String description;
  final String endDate;
  final String id;
  final String location;
  final String phone;
  final String startDate;
  final String title;
  final String map;

  GalleryModel({
    required this.qrCode,
    required this.classificationId, // إضافة classificationId
    required this.imageURL,
    required this.description,
    required this.endDate,
    required this.id,
    required this.location,
    required this.phone,
    required this.startDate,
    required this.title,
    required this.map,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json, String id) {
    return GalleryModel(
      id: id, // تعيين المعرف
      qrCode: json['QR code'] ?? '',
      classificationId: json['classification id'] != null
          ? (json['classification id'] as DocumentReference).id
          : 'default_id', // أو يمكنك استخدام قيمة افتراضية
      description: json['description'] ?? '',
      endDate: json['end date'] ?? '',
      imageURL: json['image url'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      startDate: json['start date'] ?? '',
      title: json['title'] ?? '',
      map:json['map']??'',
    );
  }
}
