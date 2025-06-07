import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedSize = 4;
  int quantity = 1;

  final List<int> availableSizes = [3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, 'cart'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Product Image
            SizedBox(
              height: 300,
              child: Image.asset(product.image, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),

            // Brand (optional)
            Text(
              product.category,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            // Product Name
            Text(
              product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Price
            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Availability
            const SizedBox(height: 6),
            const Row(
              children: [
                Text('Availability: '),
                Text(
                  'In Stock',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Size Selector
            const Text('Size :', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children:
                  availableSizes.map((size) {
                    final isSelected = size == selectedSize;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected ? Colors.yellow[200] : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.yellow : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$size',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),

            // Quantity Selector
            const Text('Select the quantity :'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) setState(() => quantity--);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Buy Now
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // You can implement a direct checkout flow here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Buy Now clicked')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 224, 242, 135),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Buy Now'),
                  ),
                ),
                const SizedBox(width: 10),

                // Add to Cart
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final cart = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      for (int i = 0; i < quantity; i++) {
                        cart.addItem(product);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $quantity item(s) to cart'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
