import 'package:flutter/material.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';

class HomeHeader extends StatelessWidget {
  final String locationName;
  final bool? isRestaurantOpen;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.locationName,
    required this.isRestaurantOpen,
    required this.unreadCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      strings.shawarma_4you,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),

                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.orange,
                          ),
                          onPressed: onNotificationTap,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        locationName.isEmpty ? strings.loading : locationName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isRestaurantOpen == null
                  ? const Color(0xFFF1F1F1)
                  : isRestaurantOpen!
                  ? const Color(0xFFE8F5E9) // أخضر خفيف
                  : const Color(0xFFFFEBEE), // أحمر خفيف
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRestaurantOpen == null
                    ? Colors.grey.shade400
                    : isRestaurantOpen!
                    ? Colors.green.shade300
                    : Colors.red.shade300,
                width: 1,
              ),
            ),
            child: Text(
              isRestaurantOpen == null
                  ? strings.verifying
                  : isRestaurantOpen!
                  ? strings.available
                  : strings.closed,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isRestaurantOpen == null
                    ? Colors.grey.shade700
                    : isRestaurantOpen!
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
