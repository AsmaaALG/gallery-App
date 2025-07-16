class SuiteModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? main_image;
  final String galleryId;
  final double price;
  final double size;
  final String title_on_map;
  final int? status;

  SuiteModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.imageUrl,
      required this.galleryId,
      required this.price,
      required this.size,
      required this.title_on_map,
      this.main_image,
      this.status});

  factory SuiteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SuiteModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['map image'] ?? '',
      galleryId: data['gallery id'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] is double)
              ? data['price']
              : 0.0,
      size: (data['size'] is int)
          ? (data['size'] as int).toDouble()
          : (data['size'] is double)
              ? data['size']
              : 0.0,
      title_on_map: data['title on map'] ?? '',
      main_image: data['main image'] ?? '',
      status: data['status'] ?? 0,
    );
  }
}
