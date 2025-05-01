class SuiteImage {
  final String id; // معرف الصورة
  final String imageUrl; // رابط الصورة
  final String suiteId; // معرف الجناح

  SuiteImage({
    required this.id,
    required this.imageUrl,
    required this.suiteId,
  });

  factory SuiteImage.fromJson(Map<String, dynamic> json, String id) {
    return SuiteImage(
      id: id,
      imageUrl: json['image url'] ?? '',
      suiteId: json['suite id'] ?? '',
    );
  }
}
