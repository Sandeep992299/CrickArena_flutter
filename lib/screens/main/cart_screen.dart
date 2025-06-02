import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/cart_provider.dart';

// ✅ Store your API key securely in a .env file or backend
const String sendGridApiKey =
    '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'; // Replace with actual key

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> sendInvoiceEmail(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // 🧾 Build invoice details
    String invoice = '🧾 Invoice Details\n\n';
    cart.items.forEach((key, item) {
      invoice +=
          '${item.product.name} - Rs. ${item.product.price} x ${item.quantity} = Rs. ${(item.product.price * item.quantity).toStringAsFixed(2)}\n';
    });
    invoice +=
        '\nTotal: Rs. ${cart.totalAmount.toStringAsFixed(2)}\n\nThank you for shopping with CrickArena!';

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
          "email":
              "kandyrailwaystationofficial@gmail.com", // Must be verified in SendGrid
          "name": "CrickArena",
        },
        "content": [
          {"type": "text/plain", "value": invoice},
        ],
      }),
    );

    debugPrint('SendGrid response: ${response.statusCode}');
    debugPrint('SendGrid body: ${response.body}');

    if (response.statusCode == 202) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Invoice sent to dissanayakesandeep@gmail.com'),
        ),
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
      appBar: AppBar(title: const Text('My Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) {
                final item = cart.items.values.toList()[i];
                return ListTile(
                  leading: Image.asset(item.product.image, width: 50),
                  title: Text(item.product.name),
                  subtitle: Text(
                    'Rs. ${item.product.price} x ${item.quantity}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => cart.removeItem(item.product.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: Rs. ${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _checkout(context),
                  child: const Text('Checkout & Send Invoice'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
