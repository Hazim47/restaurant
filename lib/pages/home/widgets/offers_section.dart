import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shawarma_4you/widgets/offer_card.dart';

class OffersSection extends StatelessWidget {
  final List<Map<String, dynamic>> offers;

  const OffersSection({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox();

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        viewportFraction: 1,
      ),
      items: offers.map((e) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: OfferCard(offer: e),
        );
      }).toList(),
    );
  }
}
