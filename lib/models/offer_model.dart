class OfferModel {
  final int id;
  final String title;
  final String subtitle;
  final String subtitle2;
  final String imageUrl;

  OfferModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.subtitle2,
    required this.imageUrl,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'],
      title: json['title'] ?? "",
      subtitle: json['subtitle'] ?? "",
      subtitle2: json['subtitle2'] ?? "",
      imageUrl: json['image_url'] ?? "",
    );
  }
}
