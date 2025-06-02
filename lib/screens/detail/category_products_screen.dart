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
  List<Product> _categoryProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    final String response = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final List<dynamic> data = json.decode(response);
    final List<Product> products =
        data.map((item) => Product.fromJson(item)).toList();

    final List<Product> filtered =
        products
            .where(
              (product) =>
                  product.category.toLowerCase() ==
                  widget.category.toLowerCase(),
            )
            .toList();

    setState(() {
      _categoryProducts = filtered;
      _filteredProducts = filtered;
    });
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _categoryProducts);
    } else {
      setState(() {
        _filteredProducts =
            _categoryProducts
                .where(
                  (product) =>
                      product.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.yellow[100],
        elevation: 1,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search ${widget.category}...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterProducts('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🧱 Product Grid
          Expanded(
            child:
                _filteredProducts.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder:
                          (ctx, i) =>
                              ProductCard(product: _filteredProducts[i]),
                    ),
          ),
        ],
      ),
    );
  }
}
