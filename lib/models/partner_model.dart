class PartnerModel {
  final String id; // معرف الشريك
  final String galleryId; // معرف المعرض
  final String image; // رابط الصورة
  final String name; // اسم الشريك

  PartnerModel({
    required this.id,
    required this.galleryId,
    required this.image,
    required this.name,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json, String id) {
    return PartnerModel(
      id: id,
      galleryId: json['gallery id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '', // تأكد من إضافة هذا الحقل إذا كان موجودًا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallery id': galleryId,
      'image': image,
      'name': name, // تأكد من إضافة هذا الحقل إذا كان موجودًا
    };
  }
}
