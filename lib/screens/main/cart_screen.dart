import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/cart_provider.dart';
import 'payment_screen.dart';

const String sendGridApiKey =
    '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'; // Replace with your real key

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> sendInvoiceEmail(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    const shippingFee = 6000.0;

    // Constructing HTML content
    String invoiceHtml = """
    <html>
      <body style="font-family: Arial, sans-serif; padding: 16px; background-color: #f9f9f9;">
        <h2 style="color: #333;">🧾 Your Invoice from CrickArena</h2>
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Image</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Product</th>
              <th style="text-align: center; border-bottom: 1px solid #ccc; padding: 8px;">Qty</th>
              <th style="text-align: right; border-bottom: 1px solid #ccc; padding: 8px;">Total</th>
            </tr>
          </thead>
          <tbody>
    """;

    cart.items.forEach((key, item) {
      final product = item.product;
      final total = product.price * item.quantity;
      final imageUrl =
          product.image.startsWith('http')
              ? product.image
              : 'https://via.placeholder.com/80x60?text=Image';

      invoiceHtml += """
        <tr>
          <td style="padding: 8px;"><img src="$imageUrl" width="60" height="60" style="object-fit: cover; border-radius: 8px;"></td>
          <td style="padding: 8px;">
            <strong>${product.name}</strong><br>
            <small style="color: #555;">${product.brand ?? ''}</small>
          </td>
          <td style="text-align: center; padding: 8px;">${item.quantity}</td>
          <td style="text-align: right; padding: 8px;">Rs. ${total.toStringAsFixed(2)}</td>
        </tr>
      """;
    });

    invoiceHtml += """
          </tbody>
        </table>
        <div style="margin-top: 20px; padding-top: 10px; border-top: 1px solid #ddd;">
          <p>Shipping Fee: <strong>Rs. ${shippingFee.toStringAsFixed(2)}</strong></p>
          <p>Total Amount: <strong style="font-size: 18px; color: #d9534f;">Rs. ${(cart.totalAmount + shippingFee).toStringAsFixed(2)}</strong></p>
        </div>
        <p style="margin-top: 30px;">Thank you for shopping with <strong>CrickArena</strong>! 🏏</p>
      </body>
    </html>
    """;

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
          {"type": "text/html", "value": invoiceHtml},
        ],
      }),
    );

    if (response.statusCode == 202) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Invoice sent successfully')),
      );
    } else {
      throw Exception('Email send failed: ${response.body}');
    }
  }

  void _checkout(BuildContext context) async {
    try {
      await sendInvoiceEmail(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invoice failed, continuing to payment'),
        ),
      );
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const PaymentScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text('Are you sure you want to clear your cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).clearCart();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🗑️ Cart cleared')),
                  );
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    const shippingFee = 6000.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                child: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _confirmClearCart(context),
                ),
              ),
            ],
          ),
          Expanded(
            child:
                cart.itemCount == 0
                    ? const Center(child: Text("🛒 Your cart is empty"))
                    : ListView.builder(
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
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item.product.image,
                                    height: 80,
                                    width: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
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
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
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
                                  onPressed:
                                      () => cart.removeItem(item.product.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (cart.itemCount > 0)
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
                    const Text('Shipping Fee: Rs.6000.00'),
                    const SizedBox(height: 4),
                    Text(
                      'Sub Total: Rs.${(cart.totalAmount + shippingFee).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          if (cart.itemCount > 0)
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
