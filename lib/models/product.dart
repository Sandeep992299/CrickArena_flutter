class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String? brand;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      image: json['image'],
      brand: json['brand'],
    );
  }
}
