class Category {
  final int id;
  final String name;
  final String description;
  final String urlImagen;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.urlImagen,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      urlImagen: json['url_image'],
    );
  }
}
