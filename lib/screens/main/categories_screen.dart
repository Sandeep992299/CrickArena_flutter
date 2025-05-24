import 'package:flutter/material.dart';
import '../detail/category_products_screen.dart'; // Import the detail screen

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({super.key});

  final List<String> categories = ['Bats', 'Balls', 'Gear', 'Promotions'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              categories[index],
              style: const TextStyle(fontSize: 18),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          CategoryProductsScreen(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
