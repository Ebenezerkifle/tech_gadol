class ProductCategory {
  final String slug;
  final String name;
  final String url;

  ProductCategory({required this.slug, required this.name, required this.url});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      slug: json['slug'],
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'slug': slug, 'name': name, 'url': url};
  }
}
