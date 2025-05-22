class SuiteImageModel {
  final String id; // معرف الصورة
  final String imageUrl; // رابط الصورة
  final String suiteId; // معرف الجناح

  SuiteImageModel({
    required this.id,
    required this.imageUrl,
    required this.suiteId,
  });

  factory SuiteImageModel.fromJson(Map<String, dynamic> json, String id) {
    return SuiteImageModel(
      id: id,
      imageUrl: json['image url'] ?? '',
      suiteId: json['suite id'] ?? '',
    );
  }
}
