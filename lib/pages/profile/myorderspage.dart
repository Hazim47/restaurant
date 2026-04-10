import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';
import 'dart:async';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
    listenOrdersRealtime();

    // تحديث can_delete كل دقيقة
    Timer.periodic(Duration(minutes: 1), (_) async {
      // حدث can_delete في قاعدة البيانات
      await supabase
          .from('orders')
          .update({'can_delete': false})
          .lte(
            'created_at',
            DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
          )
          .eq('can_delete', true);

      if (mounted) setState(() {});
    });
  }

  Future<void> fetchOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', user.id)
        .filter('status', 'in', ['pending', 'accepted'])
        .eq('is_deleted_by_user', false)
        .order('created_at', ascending: false);

    setState(() {
      orders = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> deleteOrder(int orderId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final strings = AppStrings.of(context);

    try {
      await supabase
          .from('orders')
          .delete()
          .eq('id', orderId)
          .eq('user_id', user.id)
          .select();

      setState(() {
        orders.removeWhere((order) => order['id'] == orderId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.order_deleted)));
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.orderError)));
    }
  }

  void listenOrdersRealtime() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final channel = supabase.channel('orders_channel');

    // عند إدخال طلب جديد
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) {
        final newOrder = payload.newRecord;
        if (newOrder['status'] == 'pending' ||
            newOrder['status'] == 'accepted') {
          setState(() => orders.insert(0, newOrder));
        }
      },
    );

    // عند تحديث الطلب
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) {
        final updatedOrder = payload.newRecord;

        setState(() {
          if (updatedOrder['status'] == 'rejected') {
            orders.removeWhere((o) => o['id'] == updatedOrder['id']);
          } else {
            final index = orders.indexWhere(
              (o) => o['id'] == updatedOrder['id'],
            );
            if (index != -1) {
              orders[index] = updatedOrder;
            } else if (updatedOrder['status'] == 'pending' ||
                updatedOrder['status'] == 'accepted') {
              orders.insert(0, updatedOrder);
            }
          }
        });
      },
    );

    // عند حذف الطلب
    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) {
        final oldOrder = payload.oldRecord;
        setState(() {
          orders.removeWhere((o) => o['id'] == oldOrder['id']);
        });
      },
    );

    channel.subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myCurrentOrders),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xff1E1E1E) : Colors.grey.shade200,
      body: orders.isEmpty
          ? Center(
              child: Text(
                strings.noOrders,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                // زر الحذف متاح فقط خلال أول 5 دقائق
                final canDelete = order['can_delete'] == true;
                final orderItems = List<Map<String, dynamic>>.from(
                  order['order_items'] ?? [],
                );
                double totalItems = orderItems.fold(
                  0,
                  (sum, item) =>
                      sum + (item['price'] ?? 0) * (item['quantity'] ?? 1),
                );
                double delivery = (order['delivery_price'] ?? 0).toDouble();
                double total = totalItems + delivery;

                return Card(
                  color: isDark ? const Color(0xff2A2A2A) : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${strings.name}: ${order['customer_name'] ?? ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${strings.phone}: ${order['phone'] ?? ''}",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (order['delivery_type'] == "delivery")
                          Builder(
                            builder: (_) {
                              String locationText = order['location'] ?? '';
                              String detailed = order['detailed_address'] ?? '';
                              String finalLocation = detailed.isNotEmpty
                                  ? "$locationText / $detailed"
                                  : locationText;
                              return Text(
                                "📍 ${strings.location}: $finalLocation",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : null,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        Text(
                          strings.items,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.amber : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...orderItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "${item['product_name']} ×${item['quantity']} = ${(item['price'] * item['quantity']).toStringAsFixed(2)} JD",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${strings.total}: ${total.toStringAsFixed(2)} JD",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.greenAccent : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${strings.orderStatus}: ${order['status'] ?? ''}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: canDelete
                                  ? () => deleteOrder(order['id'])
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canDelete
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              child: Text(strings.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
