import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shawarma_4you/core/services/supabase_service.dart';
import 'package:shawarma_4you/core/services/location_service.dart';
import '../profile/profile_page.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shawarma_4you/managers/favorites_manager.dart';
import 'dart:convert';
import '../notification/notifications_page.dart';
import 'widgets/home_header.dart';
import 'widgets/offers_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/products_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static List<Map<String, dynamic>> cachedProducts = [];
  static List<Map<String, dynamic>> cachedOffers = [];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  bool? isRestaurantOpen;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> offers = [];
  String locationName = "";
  Set<String> deletedNotificationIds = {};
  Set<String> favoriteIds = {};
  List<Map<String, dynamic>> notifications = [];
  int unreadCount = 0;
  bool isLoading = true;

  final supabase = Supabase.instance.client;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();

    loadCachedStatus();
    loadCachedData();

    Future.microtask(loadData);
    SupabaseService.refreshData();
    Future.delayed(const Duration(milliseconds: 500), () async {
      await loadAppStatus();
      subscribeAppStatus();
    });

    Future.delayed(const Duration(seconds: 1), () async {
      await loadFavorites();
      await FavoritesManager.loadFavorites();
      if (mounted) setState(() {});
    });

    Future.delayed(const Duration(seconds: 2), () async {
      await loadNotifications();
      subscribeNotifications();
    });

    Future.delayed(const Duration(seconds: 5), () {
      _loadLocation();
      loadDeletedNotifications();
    });
  }

  // ============================
  // الكاش
  // ============================

  Future<void> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final productsString = prefs.getString('cached_products');
    final offersString = prefs.getString('cached_offers');

    if (productsString != null && offersString != null) {
      products = List<Map<String, dynamic>>.from(jsonDecode(productsString));
      offers = List<Map<String, dynamic>>.from(jsonDecode(offersString));

      isLoading = false;
      setState(() {});
    }
  }

  Future<void> loadDeletedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    deletedNotificationIds =
        (prefs.getStringList('deleted_notifications') ?? []).toSet();
  }

  Future<void> deleteNotification(String id) async {
    deletedNotificationIds.add(id);

    // حفظ محلي
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'deleted_notifications',
      deletedNotificationIds.toList(),
    );

    // حذف من قاعدة البيانات
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase
          .from('notifications')
          .delete()
          .eq('id', int.parse(id))
          .eq('user_id', user.id);
    }

    setState(() {
      notifications.removeWhere((n) => n['id'].toString() == id);
      unreadCount = notifications.where((n) => n['is_read'] == false).length;
    });
  }

  // ============================
  // DATA
  // ============================

  Future loadData() async {
    if (HomePage.cachedProducts.isEmpty) {
      HomePage.cachedProducts = await SupabaseService.getProducts();
    }
    if (HomePage.cachedOffers.isEmpty) {
      HomePage.cachedOffers = await SupabaseService.getOffers();
    }

    if (!mounted) return;

    products = HomePage.cachedProducts;
    offers = HomePage.cachedOffers;
    isLoading = false;

    setState(() {});
  }

  Future<void> _loadLocation() async {
    setState(() => locationName = "جاري تحديد الموقع...");

    final locationData = await LocationService.getLocation();

    if (!mounted) return;

    setState(() {
      locationName = locationData?["address"] ?? "موقع غير معروف";
    });
  }

  Future<void> loadFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('favorites')
        .select('product')
        .eq('user_id', user.id);

    favoriteIds = res.map((e) => e['product']['id'].toString()).toSet();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadProductsAndOffers() async {
    if (HomePage.cachedProducts.isEmpty) {
      HomePage.cachedProducts = await SupabaseService.getProducts();
    }
    if (HomePage.cachedOffers.isEmpty) {
      HomePage.cachedOffers = await SupabaseService.getOffers();
    }

    if (!mounted) return;

    setState(() {
      products = HomePage.cachedProducts;
      offers = HomePage.cachedOffers;
    });
  }

  // ============================
  // STATUS
  // ============================

  Future<void> loadAppStatus() async {
    final data = await supabase
        .from('app_status')
        .select('is_open')
        .eq("id", 1)
        .single();

    bool newStatus = data['is_open'] ?? false;

    if (!mounted) return;

    setState(() => isRestaurantOpen = newStatus);
  }

  void subscribeAppStatus() {
    supabase
        .channel('app_status_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'app_status',
          callback: (payload) {
            if (!mounted) return;
            setState(() => isRestaurantOpen = payload.newRecord['is_open']);
          },
        )
        .subscribe();
  }

  Future<void> loadCachedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool('app_status');

    if (cached != null) {
      isRestaurantOpen = cached;
      setState(() {});
    }
  }

  // ============================
  // NOTIFICATIONS
  // ============================

  Future<void> loadNotifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) return; // حماية من null
    final userId = user.id;

    final data = await supabase
        .from('notifications')
        .select('id,title,body,is_read,created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    notifications = List<Map<String, dynamic>>.from(
      data.where((n) => !deletedNotificationIds.contains(n['id'].toString())),
    );

    unreadCount = notifications.where((n) => n['is_read'] == false).length;

    if (!mounted) return;
    setState(() {});
  }

  void subscribeNotifications() {
    final user = supabase.auth.currentUser;
    if (user == null || _subscribed) return;

    _subscribed = true;

    supabase
        .channel('user_notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final n = payload.newRecord;

            if (n['user_id'].toString() != user.id) return;

            if (!mounted) return;

            setState(() {
              if (!deletedNotificationIds.contains(n['id'].toString())) {
                setState(() {
                  notifications.insert(0, n);
                  if (n['is_read'] == false) unreadCount++;
                });
              }
            });
          },
        )
        .subscribe();
  }

  // ============================
  // FILTER
  // ============================

  Future fetchProducts(String category, String allKey) async {
    if (category == allKey) {
      setState(() {
        products = HomePage.cachedProducts;
      });
      return;
    }

    final data = await SupabaseService.getProductsByCategory(category);

    if (!mounted) return;

    setState(() {
      products = data;
    });
  }

  // ============================
  // UI
  // ============================

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    final categories = [
      s.all,
      s.shawarma,
      s.snacks,
      s.familyMeals,
      s.drinks,
      s.broasted,
      s.sauces,
    ];

    return Scaffold(
      endDrawer: const ProfilePage(),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await loadAppStatus();
                await loadNotifications();
                await _loadProductsAndOffers();
              },
              child: ListView(
                children: [
                  HomeHeader(
                    locationName: locationName,
                    isRestaurantOpen: isRestaurantOpen,
                    unreadCount: unreadCount,
                    onNotificationTap: () async {
                      final userId = supabase.auth.currentUser!.id;

                      await supabase
                          .from('notifications')
                          .update({'is_read': true})
                          .eq('user_id', userId);

                      final updated =
                          await Navigator.push<List<Map<String, dynamic>>>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationsPage(
                                notifications: notifications, // ⚡ هذا مهم
                                onDeleteNotification: deleteNotification,
                              ),
                            ),
                          );

                      if (updated != null) {
                        setState(() {
                          notifications = updated;
                          unreadCount = notifications
                              .where((n) => n['is_read'] == false)
                              .length;
                        });
                      }
                    },
                  ),

                  OffersSection(offers: offers),

                  const SizedBox(height: 15),

                  CategoriesSection(
                    categories: categories,
                    selectedIndex: selectedCategory,
                    onTap: (index) {
                      setState(() => selectedCategory = index);
                      fetchProducts(categories[index], categories[0]);
                    },
                  ),

                  const SizedBox(height: 10),

                  ProductsSection(
                    products: products,
                    favoriteIds: favoriteIds,
                    isRestaurantOpen: isRestaurantOpen ?? false,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
