import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.amber
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: selected ? Colors.amber : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.black87
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              shadows: selected
                  ? [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                        color: Colors.black26,
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}
