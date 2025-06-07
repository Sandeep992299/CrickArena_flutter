import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../providers/cart_provider.dart';
import 'payment_screen.dart';

const String sendGridApiKey = '';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> sendInvoiceEmail(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    const shippingFee = 6000.0;

    String invoiceHtml = """
<html>
  <head>
    <style>
      body {
        font-family: 'Segoe UI', Roboto, sans-serif;
        padding: 20px;
        background-color: #f2f4f6;
        color: #333;
      }

      .container {
        max-width: 700px;
        margin: auto;
        background-color: #fff;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0,0,0,0.05);
        padding: 30px;
      }

      .header {
        text-align: center;
        padding-bottom: 20px;
        border-bottom: 2px solid #eaeaea;
      }

      .header h1 {
        margin: 0;
        color: #ff5722;
      }

      .header img {
        height: 60px;
        margin-bottom: 10px;
      }

      table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
      }

      th, td {
        padding: 12px;
        text-align: left;
      }

      th {
        background-color: #f9f9f9;
        border-bottom: 1px solid #ccc;
      }

      tr:nth-child(even) {
        background-color: #f6f6f6;
      }

      .total {
        text-align: right;
        font-weight: bold;
        font-size: 16px;
        padding-top: 10px;
      }

      .footer {
        margin-top: 30px;
        font-size: 13px;
        color: #777;
        text-align: center;
        border-top: 1px solid #ddd;
        padding-top: 15px;
      }

      .highlight {
        color: #ff5722;
        font-weight: bold;
      }

      .thank-you {
        font-size: 16px;
        margin-top: 30px;
        color: #2e7d32;
        text-align: center;
      }
    </style>
  </head>

  <body>
    <div class="container">
      <div class="header">
        <img src="https://github.com/Sandeep992299/CrickArena_flutter/blob/main/assets/images/CRrgan%201.png?raw=true" alt="CrickArena Logo">
        <h1>🧾 Invoice from CrickArena</h1>
        <p>Your one-stop cricket shop 🏏</p>
      </div>

      <table>
        <thead>
          <tr>
            <th>Image</th>
            <th>Product</th>
            <th style="text-align:center;">Qty</th>
            <th style="text-align:right;">Total</th>
          </tr>
        </thead>
        <tbody>
""";

    // Add each item in the cart
    cart.items.forEach((key, item) {
      final product = item.product;
      final total = product.price * item.quantity;
      final imageUrl =
          product.image.startsWith('http')
              ? product.image
              : 'https://via.placeholder.com/80x60?text=Image';

      invoiceHtml += """
    <tr>
      <td><img src="$imageUrl" width="60" height="60" style="border-radius:6px; object-fit:cover;"></td>
      <td>
        <strong>${product.name}</strong><br>
        <span style="color: #555;">${product.brand ?? ''}</span>
      </td>
      <td style="text-align:center;">${item.quantity}</td>
      <td style="text-align:right;">Rs. ${total.toStringAsFixed(2)}</td>
    </tr>
  """;
    });

    invoiceHtml += """
        </tbody>
      </table>

      <div class="total">
        <p>Shipping Fee: Rs. ${shippingFee.toStringAsFixed(2)}</p>
        <p>Total Amount: <span class="highlight">Rs. ${(cart.totalAmount + shippingFee).toStringAsFixed(2)}</span></p>
      </div>

      <p class="thank-you">🙏 Thank you for shopping with <strong>CrickArena</strong>!</p>

      <div class="footer">
        <p><strong>CrickArena (Pvt) Ltd</strong><br>
        123 Cricket Avenue, Colombo 07, Sri Lanka<br>
        Hotline: +94 77 123 4567<br>
        Email: support@crickarena.lk</p>
        <p>&copy; ${DateTime.now().year} CrickArena. All rights reserved.</p>
      </div>
    </div>
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
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/cart.json',
                            height: 250,
                            width: 250,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "🛒 Your cart is empty",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
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
