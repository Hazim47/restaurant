class ProductModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? "",
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? "",
      category: json['category'] ?? "",
      description: json['description'] ?? "",
    );
  }
}
