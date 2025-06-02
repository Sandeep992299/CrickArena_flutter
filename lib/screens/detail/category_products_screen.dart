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

  String _selectedSort = 'None';
  String _selectedBrand = 'All';

  List<String> _availableBrands = [];

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

    final brands =
        filtered
            .map((e) => e.brand ?? '')
            .toSet()
            .where((b) => b.isNotEmpty)
            .toList();
    brands.sort();

    setState(() {
      _categoryProducts = filtered;
      _filteredProducts = filtered;
      _availableBrands = ['All', ...brands];
    });
  }

  void _applyFilters() {
    List<Product> result = List.from(_categoryProducts);

    // Search filter
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result =
          result.where((p) => p.name.toLowerCase().contains(query)).toList();
    }

    // Brand filter
    if (_selectedBrand != 'All') {
      result =
          result
              .where(
                (p) =>
                    (p.brand ?? '').toLowerCase() ==
                    _selectedBrand.toLowerCase(),
              )
              .toList();
    }

    // Sort
    if (_selectedSort == 'Price: Low → High') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Price: High → Low') {
      result.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() => _filteredProducts = result);
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Search ${widget.category}...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
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

          // 🔽 Dropdown Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                // Sort Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSort,
                    onChanged: (val) {
                      setState(() => _selectedSort = val ?? 'None');
                      _applyFilters();
                    },
                    items:
                        ['None', 'Price: Low → High', 'Price: High → Low']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      labelText: "Sort by",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Brand Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    onChanged: (val) {
                      setState(() => _selectedBrand = val ?? 'All');
                      _applyFilters();
                    },
                    items:
                        _availableBrands
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      labelText: "Brand",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🧱 Product Grid
          Expanded(
            child:
                _filteredProducts.isEmpty
                    ? const Center(
                      child: Text('No products match your filters.'),
                    )
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
