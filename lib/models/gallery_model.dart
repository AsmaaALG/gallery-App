import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryModel {
  final String qrCode;
  final String classificationId;
  final String imageURL;
  final String description;
  final String endDate;
  final String id;
  final String location;
  final String startDate;
  final String title;
  final String map;
  final String company_id;
  final String city;

  GalleryModel({
    required this.qrCode,
    required this.classificationId,
    required this.imageURL,
    required this.description,
    required this.endDate,
    required this.id,
    required this.location,
    required this.startDate,
    required this.title,
    required this.map,
    required this.company_id,
    required this.city,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json, String id) {
    return GalleryModel(
      id: id, 
      qrCode: json['QR code'] ?? '',
      classificationId: json['classification id'] != null
          ? (json['classification id'] as DocumentReference).id
          : 'default_id', 
      description: json['description'] ?? '',
      endDate: json['end date'] ?? '',
      imageURL: json['image url'] ?? '',
      location: json['location'] ?? '',
      startDate: json['start date'] ?? '',
      title: json['title'] ?? '',
      map: json['map'] ?? '',
      city: json['city'] ?? '',
      company_id: json['company_id'] ?? '',
    );
  }
}
