class SuiteModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String galleryId; // إضافة حقل galleryId

  SuiteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.galleryId, // إضافة الحقل في المُنشئ
  });

  factory SuiteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SuiteModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['main image'] ?? '',
      galleryId: data['gallery id'] ?? '', // إضافة الحقل من البيانات
    );
  }

  get mainImage => null;
}
