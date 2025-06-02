import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/cart_provider.dart';

const String sendGridApiKey =
    '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';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> sendInvoiceEmail(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    String invoice = '🧾 Invoice Details\n\n';
    cart.items.forEach((key, item) {
      invoice +=
          '${item.product.name} - Rs. ${item.product.price} x ${item.quantity} = Rs. ${(item.product.price * item.quantity).toStringAsFixed(2)}\n';
    });
    invoice += '\nTotal: Rs. ${cart.totalAmount.toStringAsFixed(2)}';

    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $sendGridApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": "dissanayakesandeep@gmail.com"},
            ],
            "subject": "Your Invoice from CrickArena",
          },
        ],
        "from": {
          "email": "kandyrailwaystationofficial@gmail.com",
          "name": "CrickArena",
        },
        "content": [
          {"type": "text/plain", "value": invoice},
        ],
      }),
    );

    if (response.statusCode == 202) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Invoice sent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to send invoice: ${response.body}')),
      );
    }
  }

  void _checkout(BuildContext context) async {
    await sendInvoiceEmail(context);
    Provider.of<CartProvider>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Curved Yellow AppBar
          Stack(
            children: [
              Container(
                height: 130,
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'My Cart',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 16,
                child: Icon(Icons.delete, color: Colors.black),
              ),
            ],
          ),

          // Cart Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) {
                final item = cart.items.values.toList()[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          item.product.image,
                          height: 80,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                item.product.brand ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rs. ${item.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        cart.updateQuantity(
                                          item.product.id,
                                          item.quantity - 1,
                                        );
                                      }
                                    },
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      cart.updateQuantity(
                                        item.product.id,
                                        item.quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => cart.removeItem(item.product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Summary Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items: x${cart.itemCount}'),
                  const SizedBox(height: 4),
                  const Text('Shipping Fee:  Rs.6000.00'),
                  const SizedBox(height: 4),
                  Text(
                    'Sub Total:  Rs.${(cart.totalAmount + 6000).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Checkout Button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () => _checkout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Check Out',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
