import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';
import 'package:shawarma_4you/managers/cart_manager.dart';
import 'package:shawarma_4you/managers/favorites_manager.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> favorites = [];
  bool isLoading = false;

  /// 🔥 كاش داخل الذاكرة
  static List<Map<String, dynamic>> cachedFavorites = [];

  @override
  void initState() {
    super.initState();

    /// عرض الكاش مباشرة بدون تحميل
    if (cachedFavorites.isNotEmpty) {
      favorites = List.from(cachedFavorites);
    }

    /// تحميل بالخلفية بدون ما يعلق الصفحة
    loadFavoritesPage();
  }

  Future<void> loadFavoritesPage() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final res = await supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id);

      final seen = <int>{};
      final freshData = res
          .map<Map<String, dynamic>>(
            (f) => f['product'] as Map<String, dynamic>,
          )
          .where((p) {
            if (seen.contains(p['id'])) return false;
            seen.add(p['id']);
            return true;
          })
          .toList();

      /// تحديث الكاش
      cachedFavorites = List.from(freshData);

      /// تحديث الواجهة بدون loading
      setState(() {
        favorites = freshData;
      });
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  Future<void> removeFavorite(Map item) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await FavoritesManager.toggleFavorite(item);

    setState(() {
      favorites.removeWhere((p) => p['id'] == item['id']);
      cachedFavorites = List.from(favorites); // تحديث الكاش
    });
  }

  void addToCart(Map item) {
    final category = (item['category'] ?? '').toString().trim();

    if (category == "سناكات") {
      showSnackOptions(context, item);
    } else {
      CartManager.addToCart(Map<String, dynamic>.from(item));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 700),
          content: Text("تمت الإضافة إلى السلة"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppStrings.of(context).favorites,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      /// ❌ ما في loading
      body: favorites.isEmpty
          ? Center(
              child: Text(
                AppStrings.of(context).emptyCart,
                style: TextStyle(color: theme.hintColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (_, i) {
                final item = favorites[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// 🔥 صورة مع كاش احترافي
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl:
                              item['image_url'] ??
                              "https://i.imgur.com/4QfKuz1.png",
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,

                          /// placeholder خفيف بدون lag
                          placeholder: (_, __) => Container(
                            width: 75,
                            height: 75,
                            color: Colors.grey.shade200,
                          ),

                          errorWidget: (_, __, ___) => Container(
                            width: 75,
                            height: 75,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error, color: Colors.red),
                          ),

                          fadeInDuration: const Duration(milliseconds: 200),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${item['price']} JD",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.favorite),
                        color: Colors.red,
                        onPressed: () => removeFavorite(item),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => addToCart(item),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void showSnackOptions(BuildContext context, Map item) {
    final sandwichPrice = item["sandwich_price"] ?? item["price"];
    final mealPrice = item["meal_price"] ?? item["price"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "اختر نوع السناك",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _optionTile(context, "سندويشة", sandwichPrice, item, "sandwich"),
              const SizedBox(height: 10),
              _optionTile(context, "وجبة", mealPrice, item, "meal"),
            ],
          ),
        );
      },
    );
  }

  Widget _optionTile(
    BuildContext context,
    String title,
    dynamic price,
    Map item,
    String type,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(title),
      trailing: Text(
        "$price JD",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        final newItem = Map<String, dynamic>.from(item);
        newItem["price"] = price;
        newItem["type"] = type;
        CartManager.addToCart(newItem);
        Navigator.pop(context);
      },
    );
  }
}
