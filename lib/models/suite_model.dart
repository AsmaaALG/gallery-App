class SuiteModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String main_image;
  final String galleryId;
  final String price;
  final String size;
  final String title_on_map;
  final int status;

  SuiteModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.imageUrl,
      required this.galleryId,
      required this.price,
      required this.size,
      required this.title_on_map,
      required this.main_image,
      required this.status});

  factory SuiteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SuiteModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['map image'] ?? '',
      galleryId: data['gallery id'] ?? '',
      price: data['price'] ?? '',
      size: data['size'] ?? '',
      title_on_map: data['title_on_map'] ?? '',
      main_image: data['main image'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
