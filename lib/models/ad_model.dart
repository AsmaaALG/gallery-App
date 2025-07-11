import 'package:cloud_firestore/cloud_firestore.dart';

class Suite {
  final String name;
  final String area;
  final String price;

  Suite({required this.name, required this.area, required this.price});

  factory Suite.fromMap(Map<String, dynamic> data) {
    return Suite(
      name: data['name'] ?? '',
      area: data['area'] ?? '',
      price: data['price'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'price': price,
    };
  }
}

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
  final DocumentReference? classificationId;
  final String city;
  final String company_id;
  final String map;
  final List<Suite> suites;

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
    required this.city,
    required this.company_id,
    required this.map,
    required this.suites,
  });

  factory AdModel.fromMap(Map<String, dynamic> data, String documentId) {
    var suitesFromMap = <Suite>[];
    if (data['suites'] != null && data['suites'] is List) {
      suitesFromMap = List<Map<String, dynamic>>.from(data['suites'])
          .map((e) => Suite.fromMap(e))
          .toList();
    }

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
      classificationId: data['classification id'] as DocumentReference?,
      city: data['city'] ?? '',
      company_id: data['company_id'] ?? '',
      map: data['map'] ?? '',
      suites: suitesFromMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start date': startDate,
      'end date': endDate,
      'image url': imageUrl,
      'location': location,
      'QR code': qrCode,
      'classification id': classificationId,
      'city': city,
      'company_id': company_id,
      'map': map,
      'stopAd': stopAd,
      'suites': suites.map((suite) => suite.toMap()).toList(),
    };
  }
}
