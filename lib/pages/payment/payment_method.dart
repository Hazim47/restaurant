import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../managers/cart_manager.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';

class PaymentMethodPage extends StatefulWidget {
  final String name;
  final String phone;
  final String location;
  final String deliveryType;
  final double total;
  final double deliveryPrice;
  final String detailedAddress;

  const PaymentMethodPage({
    super.key,
    required this.name,
    required this.phone,
    required this.location,
    required this.deliveryType,
    required this.total,
    required this.deliveryPrice,
    required this.detailedAddress,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String paymentMethod = "cash";
  bool isSubmitting = false;
  double get itemsTotal => widget.total - widget.deliveryPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          strings.paymentMethod,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔹 TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.choosePaymentMethod,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),

            /// 💳 PAYMENT OPTIONS
            _paymentTile(theme, strings.cashOnDelivery, "cash", Icons.payments),
            const SizedBox(height: 25),

            /// 💰 PRICE DETAILS
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    theme.cardColor.withOpacity(0.9),
                    theme.cardColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _priceRow(theme, strings.orderPrice, itemsTotal),
                  _priceRow(theme, strings.delivery, widget.deliveryPrice),
                  Divider(color: theme.dividerColor, height: 25),
                  _priceRow(theme, strings.total, widget.total, isBold: true),
                ],
              ),
            ),
            const Spacer(),

            /// 🚀 CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 5,
                ),
                onPressed: isSubmitting ? null : sendOrder,
                child: Text(
                  strings.confirmOrder,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    ThemeData theme,
    String title,
    double price, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyMedium),
          Text(
            "${price.toStringAsFixed(2)} JD",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
  ) {
    final isSelected = paymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.4),
                    const Color(0xFFFFD700).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    theme.cardColor.withOpacity(0.6),
                    theme.cardColor.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD700)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
            Radio(
              value: value,
              groupValue: paymentMethod,
              activeColor: const Color(0xFFFFD700),
              onChanged: (v) => setState(() => paymentMethod = v!),
            ),
          ],
        ),
      ),
    );
  }

  Future sendOrder() async {
    final supabase = Supabase.instance.client;
    final strings = AppStrings.of(context);

    if (isSubmitting) return; // لو العملية شغالة لا تعمل شي
    isSubmitting = true;

    try {
      // 🔹 INSERT بدون select().single()
      await supabase.from('orders').insert({
        'customer_name': widget.name,
        'phone': widget.phone,
        'location': widget.location,
        'detailed_address': widget.detailedAddress,
        'delivery_type': widget.deliveryType,
        'payment_method': paymentMethod,
        'total_price': widget.total,
        'delivery_price': widget.deliveryType == "pickup"
            ? 0
            : widget.deliveryPrice,
        'items_total': itemsTotal,
        'status': 'pending',
        "user_id": supabase.auth.currentUser!.id,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      // 🔹 بعدين جيب آخر طلب
      final order = await supabase
          .from('orders')
          .select()
          .eq("user_id", supabase.auth.currentUser!.id)
          .order('id', ascending: false)
          .limit(1)
          .single();

      final orderId = order['id'];

      final items = CartManager.cart.map((item) {
        return {
          'order_id': orderId,
          'product_name': item.product['name'],
          'price': item.product['price'],
          'quantity': item.quantity,
          'type': item.product['type'],
        };
      }).toList();

      await supabase.from('order_items').insert(items);

      CartManager.cart.clear();
      await CartManager.saveCart();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.orderSuccess)));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.orderError)));
    } finally {
      isSubmitting = false; // رجع القيمة False بعد العملية
    }
  }
}
