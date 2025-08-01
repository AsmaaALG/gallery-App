import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  final String id;
  final String email; 
  final String firstName; 
  final String lastName; 
  final String phoneNumber;
  final DateTime createdAt;

  UsersModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '', 
    required this.createdAt,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber:
          json['phone_number'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'email': email,
  //     'first_name': firstName,
  //     'last_name': lastName,
  //     'phone_number': phoneNumber, 
  //     'createdAt': createdAt.toIso8601String(),
  //   };
  // }
}
