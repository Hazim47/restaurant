import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shawarma_4you/managers/cart_manager.dart';
import 'package:shawarma_4you/managers/favorites_manager.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onAdd;
  final bool isRestaurantOpen;
  final bool isFavorite;
  const ProductCard({
    super.key,
    required this.product,
    this.onAdd,
    required this.isFavorite,
    this.isRestaurantOpen = true,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  Future<void> toggleFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (widget.isFavorite) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('product->>id', widget.product['id'].toString());
    } else {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'product': widget.product,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final strings = AppStrings.of(context);

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المنتج مع كاش لتحسين الأداء
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl:
                  product['image_url'] ?? "https://i.imgur.com/4QfKuz1.png",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 80, height: 80, color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Icon(Icons.broken_image, size: 40),
            ),
          ),

          const SizedBox(width: 15),

          // الاسم والسعر
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المنتج
                Text(
                  product['name'] ?? '',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // قلل الحجم شوي
                  ),
                  maxLines: 2, // خليها سطرين بدل 1
                  overflow: TextOverflow.ellipsis,
                ),

                // وصف المنتج (لو موجود)
                if ((product['description'] ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      product['description'],
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 12, // خط أصغر
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 8),

                // السعر
                Text(
                  "\JD${product['price'] ?? 0}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // زر المفضلة
          IconButton(
            icon: Icon(
              FavoritesManager.isFavorite(widget.product['id'])
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: FavoritesManager.isFavorite(widget.product['id'])
                  ? Colors.red
                  : Colors.grey[700],
            ),
            onPressed: () async {
              await FavoritesManager.toggleFavorite(widget.product);
              setState(() {}); // إعادة بناء الكرت بعد التغيير
            },
          ),

          // زر الإضافة للسلة
          ElevatedButton(
            onPressed: widget.isRestaurantOpen ?? false
                ? () {
                    final category = (product['category'] ?? '')
                        .toString()
                        .trim();

                    if (category == "سناكات") {
                      showSnackOptions(context);
                    } else {
                      CartManager.addToCart(product);
                      if (widget.onAdd != null) widget.onAdd!();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating, // لتصبح عائمة
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.amber[700]!.withOpacity(
                            0.95,
                          ), // ذهبي شفاف يناسب الداكن
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // حواف مستديرة
                          ),
                          duration: const Duration(seconds: 1),
                          elevation: 8,
                          content: Row(
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: Colors.black,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  strings.addToCart,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                : null, // إذا المطعم مسكر يصبح الزر معطل
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isRestaurantOpen ?? false
                  ? Colors.amber
                  : Colors.grey, // تغيير اللون لو مسكر
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            child: Text(
              widget.isRestaurantOpen ?? false ? strings.add : strings.closed,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackOptions(BuildContext context) {
    final product = widget.product;

    final sandwichPrice = product["sandwich_price"] ?? product["price"];
    final mealPrice = product["meal_price"] ?? product["price"];
    final strings = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.amber[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                strings.chooseSnack,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 خيار السندويشة
              InkWell(
                onTap: () {
                  final newProduct = Map<String, dynamic>.from(product);
                  newProduct["price"] = sandwichPrice;
                  newProduct["type"] = "sandwich";
                  CartManager.addToCart(newProduct);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating, // لتصبح عائمة
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.amber[700]!.withOpacity(
                        0.95,
                      ), // ذهبي شفاف يناسب الداكن
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // حواف مستديرة
                      ),
                      duration: const Duration(seconds: 1),
                      elevation: 8,
                      content: Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.addToCart,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.shade400, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.sandwich,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "\$$sandwichPrice",
                        style: TextStyle(
                          color: Colors.amber[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 خيار الوجبة
              InkWell(
                onTap: () {
                  final newProduct = Map<String, dynamic>.from(product);
                  newProduct["price"] = mealPrice;
                  newProduct["type"] = "meal";
                  CartManager.addToCart(newProduct);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating, // لتصبح عائمة
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.amber[700]!.withOpacity(
                        0.95,
                      ), // ذهبي شفاف يناسب الداكن
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // حواف مستديرة
                      ),
                      duration: const Duration(seconds: 1),
                      elevation: 8,
                      content: Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.addToCart,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.shade400, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.meal,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "\$$mealPrice",
                        style: TextStyle(
                          color: Colors.amber[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
