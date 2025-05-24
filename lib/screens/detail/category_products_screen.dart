import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFilteredProducts();
  }

  Future<void> _loadFilteredProducts() async {
    final String response = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final List<dynamic> data = json.decode(response);
    final List<Product> products =
        data.map((item) => Product.fromJson(item)).toList();

    setState(() {
      _filteredProducts =
          products
              .where((product) => product.category == widget.category)
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category}')),
      body:
          _filteredProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder:
                    (ctx, i) => ProductCard(product: _filteredProducts[i]),
              ),
    );
  }
}
