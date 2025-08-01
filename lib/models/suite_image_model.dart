class SuiteImageModel {
  final String id; 
  final String imageUrl; 
  final String suiteId;

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
