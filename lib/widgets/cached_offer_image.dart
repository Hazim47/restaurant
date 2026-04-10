import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedOfferImage extends StatelessWidget {
  final String url;
  const CachedOfferImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, __) => Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[300],
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.error, color: Colors.red, size: 28),
        ),
      ),
    );
  }
}
