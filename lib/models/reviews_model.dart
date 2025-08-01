
class ReviewsModel {
  final String id; 
  final String galleryId; 
  final double rating; 
  final String userId;
  final DateTime date; 
  final String comment;
  String userName;

  ReviewsModel({
    required this.id,
    required this.galleryId,
    required this.rating,
    required this.userId,
    required this.date,
    required this.comment,
    required this.userName,
  });

  factory ReviewsModel.fromJson(Map<String, dynamic> json, String id) {
    return ReviewsModel(
      id: id,
      comment: json['comment'] ?? '',
      galleryId: json['gallery id'] ?? '',
      rating: (json['number of stars'] as num).toDouble(),
      userId: json['user id'] ?? '',
      date: DateTime.parse(
          json['date'] ?? DateTime.now().toIso8601String()), 
      userName: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallery id': galleryId,
      'number of stars': rating,
      'user id': userId,
      'comment': comment,
    };
  }
}
