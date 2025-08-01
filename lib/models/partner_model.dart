class PartnerModel {
  final String id; 
  final String galleryId;
  final String image; 
  final String name; 

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
      name: json['name'] ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallery id': galleryId,
      'image': image,
      'name': name, 
    };
  }
}
