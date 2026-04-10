import 'package:flutter/material.dart';
import 'package:shawarma_4you/widgets/category_item.dart';

class CategoriesSection extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onTap;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryItem(
            title: categories[index],
            selected: selectedIndex == index,
            onTap: () => onTap(index),
          );
        },
      ),
    );
  }
}
