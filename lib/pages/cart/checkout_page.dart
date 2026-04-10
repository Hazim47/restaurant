import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../managers/cart_manager.dart';
import '../../core/services/location_service.dart';
import '../payment/payment_method.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final supabase = Supabase.instance.client;
  final name = TextEditingController();
  final phone = TextEditingController();
  final location = TextEditingController();
  final detailedAddress = TextEditingController();

  String deliveryType = "delivery";
  bool loadingLocation = false;

  double deliveryPrice = 0;
  double distanceKm = 0;

  static const restaurantLat = 32.072704;
  static const restaurantLng = 36.094651;

  double calculateDistance(double lat, double lng) {
    double meters = Geolocator.distanceBetween(
      restaurantLat,
      restaurantLng,
      lat,
      lng,
    );
    return meters / 1000;
  }

  double calculateDeliveryPrice(double distance) {
    return (distance / 5).ceilToDouble();
  }

  Future getLocation() async {
    setState(() => loadingLocation = true);
    final data = await LocationService.getLocation(forceRefresh: true);
    if (data != null) {
      location.text = data["address"];
      double lat = data["lat"];
      double lng = data["lng"];
      double dist = calculateDistance(lat, lng);
      double price = calculateDeliveryPrice(dist);
      setState(() {
        distanceKm = dist;
        deliveryPrice = price;
      });
    }
    setState(() => loadingLocation = false);
  }

  Future<void> addOrder(Map<String, dynamic> orderData) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('orders').insert({
      'user_id': user.id,
      'customer_name': orderData['name'],
      'phone': orderData['phone'],
      'location': orderData['location'],
      'detailed_address': orderData['detailed_address'],
      'delivery_type': orderData['deliveryType'],
      'delivery_price': orderData['deliveryPrice'],
      'status': orderData['status'],
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.checkout,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            theme,
            child: Column(
              children: [
                _sectionTitle("👤 ${strings.name}", theme, isDark),
                _input(theme, name, hint: strings.enterHere, isDark: isDark),
                const SizedBox(height: 15),
                _sectionTitle("📞 ${strings.phone}", theme, isDark),
                _input(
                  theme,
                  phone,
                  hint: strings.enterHere,
                  isDark: isDark,
                  isPhone: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _card(
            theme,
            child: Column(
              children: [
                _sectionTitle("🚚 ${strings.deliveryType}", theme, isDark),
                RadioListTile(
                  value: "delivery",
                  groupValue: deliveryType,
                  activeColor: Colors.amber,
                  onChanged: (v) => setState(() => deliveryType = v!),
                  title: Text(
                    strings.delivery,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                RadioListTile(
                  value: "pickup",
                  groupValue: deliveryType,
                  activeColor: Colors.amber,
                  onChanged: (v) {
                    setState(() {
                      deliveryType = v!;
                      deliveryPrice = 0;
                    });
                  },
                  title: Text(
                    strings.pickup,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (deliveryType == "delivery")
            _card(
              theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("📍 ${strings.location}", theme, isDark),
                  _input(
                    theme,
                    location,
                    hint: strings.enterHere,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: loadingLocation ? null : getLocation,
                    icon: const Icon(Icons.my_location),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(
                      loadingLocation
                          ? strings.detectingLocation
                          : strings.detectLocation,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _sectionTitle("🏠 ${strings.detailedAddress}", theme, isDark),
                  _input(
                    theme,
                    detailedAddress,
                    hint: strings.enterHere,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  if (distanceKm > 0)
                    Text(
                      "📏 ${strings.distance}: ${distanceKm.toStringAsFixed(2)} كم",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color.fromARGB(179, 0, 0, 0),
                      ),
                    ),
                  if (deliveryPrice > 0)
                    Text(
                      "💰 ${strings.deliveryFee}: $deliveryPrice JD",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              if (name.text.isEmpty || phone.text.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(strings.enterNamePhone)));
                return;
              }

              if (deliveryType == "delivery" &&
                  (location.text.isEmpty || detailedAddress.text.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.enterLocationDetail)),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentMethodPage(
                    name: name.text,
                    phone: phone.text,
                    location: location.text,
                    deliveryType: deliveryType,
                    total: CartManager.total() + deliveryPrice,
                    deliveryPrice: deliveryPrice,
                    detailedAddress: detailedAddress.text,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
            ),
            child: Text(
              "💳 ${strings.payment}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.black : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI Helpers ----------------

  Widget _card(ThemeData theme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.black87, width: 1), // بوردر اسود
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text, ThemeData theme, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.amber,
      ),
    ),
  );

  Widget _input(
    ThemeData theme,
    TextEditingController controller, {
    required String hint,
    bool isDark = false,
    bool isPhone = false,
  }) => TextField(
    controller: controller,
    keyboardType: isPhone ? TextInputType.number : TextInputType.text,
    inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
    style: theme.textTheme.bodyMedium?.copyWith(
      color: isDark ? Colors.white : Colors.black87,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black87, width: 1), // بوردر اسود
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black87, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.amber, width: 1.5),
      ),
    ),
  );
}
