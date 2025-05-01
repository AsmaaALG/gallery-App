class AdModel {
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String startDate;
  final String endDate;
  final String stopAd;

  AdModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.stopAd,
  });

  factory AdModel.fromMap(Map<String, dynamic> data) {
    return AdModel(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image url'] ?? '',
      location: data['location'] ?? '',
      startDate: data['start date'] ?? '',
      endDate: data['end date'] ?? '',
      stopAd: data['stopAd'] ?? '',
    );
  }
}
