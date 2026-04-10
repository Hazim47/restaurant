import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shawarma_4you/core/services/supabase_service.dart';
import 'package:shawarma_4you/widgets/category_item.dart';
import 'package:shawarma_4you/widgets/product_card.dart';
import 'package:shawarma_4you/widgets/search_bar.dart';
import '../profile/profile_page.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';
import 'package:shawarma_4you/managers/favorites_manager.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController searchController = TextEditingController();
  int selectedCategory = 0;
  List products = [];
  bool isLoading = true;
  Set<String> favoriteIds = {};
  Timer? _debounce;
  static List cachedProducts = [];
  bool? isRestaurantOpen;
  @override
  void initState() {
    super.initState();
    loadProducts();
    loadAppStatus();
    FavoritesManager.loadFavorites().then((_) {
      setState(() {}); // لإعادة بناء الصفحة بعد تحميل المفضلات
    });
  }

  Future<void> loadAppStatus() async {
    final data = await SupabaseService.supabase
        .from('app_status')
        .select()
        .eq('id', 1)
        .single();

    if (!mounted) return;

    setState(() {
      isRestaurantOpen = data['is_open'] ?? false;
    });
  }

  Future loadProducts() async {
    if (cachedProducts.isEmpty) {
      cachedProducts = await SupabaseService.getProducts();
    }

    if (!mounted) return;

    setState(() {
      products = cachedProducts;
      isLoading = false;
    });
  }

  Future fetchCategory(String category, String allKey) async {
    if (category == allKey) {
      setState(() {
        products = cachedProducts;
      });
      return;
    }

    final data = await SupabaseService.getProductsByCategory(category);

    if (!mounted) return;

    setState(() {
      products = data;
    });
  }

  void searchProducts(String text, List<String> categories) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (text.isEmpty) {
        fetchCategory(categories[selectedCategory], categories[0]);
        return;
      }

      final res = await SupabaseService.supabase
          .from("menu")
          .select()
          .ilike("name", "%$text%");

      if (!mounted) return;

      setState(() => products = res);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final categories = [
      s.all,
      s.shawarma,
      s.snacks,
      s.familyMeals,
      s.drinks,
      s.broasted,
      s.sauces,
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      endDrawer: const ProfilePage(),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔥 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[400],
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Colors.amber[400]),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade800.withOpacity(0.5),
                      Colors.grey.shade700.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SearchBarWidget(
                  controller: searchController,
                  onChanged: (text) => searchProducts(text, categories),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 📂 CATEGORIES
            SizedBox(
              height: 60,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CategoryItem(
                      title: categories[index],
                      selected: selectedCategory == index,
                      onTap: () {
                        setState(() => selectedCategory = index);
                        fetchCategory(categories[index], categories[0]);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// 🍔 PRODUCTS
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      cacheExtent: 1000, // لتسريع العرض بدون تعليق
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ProductCard(
                            key: ValueKey(item['id'] ?? index),
                            product: item,
                            isFavorite: favoriteIds.contains(
                              item['id'].toString(),
                            ),
                            isRestaurantOpen: isRestaurantOpen ?? false,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
