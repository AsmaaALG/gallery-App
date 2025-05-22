class UsersModel {
  final String id; // معرف المستخدم
  final String email; // البريد الإلكتروني
  final String firstName; // الاسم الأول
  final String lastName; // الاسم الأخير
  final String phoneNumber; // رقم الهاتف (اختياري)

  UsersModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '', // تعيين القيمة الافتراضية
  });

  // دالة لتحويل البيانات من JSON إلى كائن User
  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber:
          json['phone_number'] ?? '', // يمكنك إضافة هذا الحقل إذا كان موجودًا
    );
  }

  // دالة لتحويل كائن User إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber, // يمكن إضافة هذا الحقل
    };
  }
}
