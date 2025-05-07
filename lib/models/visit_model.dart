class VisitModel {
  final String id; // ID حق الزيارة نفسها
  final String galleryId;
  final String userId;

  VisitModel({
    required this.id,
    required this.galleryId,
    required this.userId,
  });

  // Factory method: fromJson
  factory VisitModel.fromJson(Map<String, dynamic> json, String id) {
    return VisitModel(
      id: id,
      galleryId: json['galleryId'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  // To JSON method (لو تحتاج تضيف زيارة)
  Map<String, dynamic> toJson() {
    return {
      'galleryId': galleryId,
      'userId': userId,
    };
  }
}
