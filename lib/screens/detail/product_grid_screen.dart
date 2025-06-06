import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../detail/category_products_screen.dart';

class ProductGridScreen extends StatefulWidget {
  final String profileImage;

  const ProductGridScreen({super.key, required this.profileImage});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  final String _productsUrl =
      'https://raw.githubusercontent.com/Sandeep992299/CrickArena_flutter/main/assets/data/products.json';

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // Online: try to fetch from the URL
      try {
        final response = await http.get(Uri.parse(_productsUrl));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final loadedProducts =
              data.map((item) => Product.fromJson(item)).toList();

          setState(() {
            _products = loadedProducts;
            _filteredProducts = loadedProducts;
            _isOffline = false;
          });

          // Save to local storage for offline use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('products_data', response.body);
        } else {
          // If server response is not 200, load offline data
          await _loadProductsFromLocalStorage();
        }
      } catch (e) {
        // On exception, load offline data
        await _loadProductsFromLocalStorage();
      }
    } else {
      // Offline: load from local storage
      await _loadProductsFromLocalStorage();
    }
  }

  Future<void> _loadProductsFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsJson = prefs.getString('products_data');

    if (productsJson != null) {
      final List<dynamic> data = json.decode(productsJson);
      final loadedProducts =
          data.map((item) => Product.fromJson(item)).toList();

      setState(() {
        _products = loadedProducts;
        _filteredProducts = loadedProducts;
        _isOffline = true;
      });

      // Show offline message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline, data loaded using local storage'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // No local data available, show error or empty list
      setState(() {
        _products = [];
        _filteredProducts = [];
        _isOffline = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No local data available. Connect to internet to load data.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _products);
    } else {
      setState(() {
        _filteredProducts =
            _products
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
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.only(top: 180),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySection(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      "Best Sellers",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildBestSellersGrid(),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      "Sponsored Ads",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const AdsSection(),
                  _buildCategoryGroup("Bats"),
                  _buildCategoryGroup("Balls"),
                  _buildCategoryGroup("Gear"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Welcome Back 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(widget.profileImage),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _filterProducts,
            decoration: InputDecoration(
              hintText: 'Search products...',
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
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.sports_cricket, 'label': 'Bats'},
      {'icon': Icons.sports_baseball, 'label': 'Balls'},
      {'icon': Icons.sports_mma, 'label': 'Gear'},
      {'icon': Icons.local_offer, 'label': 'Promotions'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CategoryProductsScreen(category: item['label']!),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        item['icon'] as IconData,
                        size: 28,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['label'].toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBestSellersGrid() {
    final bestSellers = _filteredProducts.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bestSellers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => ProductCard(product: bestSellers[i]),
    );
  }

  Widget _buildCategoryGroup(String category) {
    final categoryProducts =
        _filteredProducts
            .where(
              (product) =>
                  product.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();

    if (categoryProducts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            category,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categoryProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (ctx, i) => ProductCard(product: categoryProducts[i]),
        ),
      ],
    );
  }
}

class AdsSection extends StatefulWidget {
  const AdsSection({super.key});

  @override
  State<AdsSection> createState() => _AdsSectionState();
}

class _AdsSectionState extends State<AdsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _adsImages = [
    'assets/images/promo1.jpg',
    'assets/images/promo2.jpg',
    'assets/images/promo3.jpg',
    'assets/images/promo4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _adsImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _adsImages.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(_adsImages[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
