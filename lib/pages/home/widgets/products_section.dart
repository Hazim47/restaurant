import 'package:flutter/material.dart';
import 'package:shawarma_4you/widgets/product_card.dart';

class ProductsSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Set<String> favoriteIds;
  final bool isRestaurantOpen;
  final bool isLoading;

  const ProductsSection({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.isRestaurantOpen,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = products[index];

        return ProductCard(
          key: ValueKey(item['id'] ?? index),
          product: item,
          isFavorite: favoriteIds.contains(item['id'].toString()),
          isRestaurantOpen: isRestaurantOpen,
        );
      },
    );
  }
}
