class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final int size;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    this.quantity = 1,
  });
}
