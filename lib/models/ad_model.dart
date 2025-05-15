import 'package:cloud_firestore/cloud_firestore.dart';

class AdModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String startDate;
  final String endDate;
  final String stopAd;
  final String? qrCode;
  final DocumentReference? classificationId; //   يكون مرجع
  final String? phone;

  var image;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.stopAd,
    this.qrCode,
    this.classificationId,
    this.phone,
  });

  factory AdModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AdModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image url'] ?? '',
      location: data['location'] ?? '',
      startDate: data['start date'] ?? '',
      endDate: data['end date'] ?? '',
      stopAd: data['stopAd'] ?? '',
      qrCode: data['QR code'] ?? '',
      classificationId:
          data['classification id'] as DocumentReference?, // تعديل هنا
      phone: data['phone'] ?? '',
    );
  }
}
