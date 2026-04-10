import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient supabase = Supabase.instance.client;

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
    });
  }

  /// ✅ كاش للبيانات
  static List<Map<String, dynamic>> _productsCache = [];
  static List<Map<String, dynamic>> _offersCache = [];

  // ---------------------- المنتجات والعروض ----------------------

  /// 🔥 تحميل المنتجات (مع كاش)
  static Future<List<Map<String, dynamic>>> getProducts() async {
    if (_productsCache.isNotEmpty) return _productsCache;

    final res = await supabase
        .from("menu")
        .select('id,name,price,image_url,category,description') // ✅ أضفناها
        .order('id')
        .limit(50);

    _productsCache = List<Map<String, dynamic>>.from(res);
    return _productsCache;
  }

  static Future<List<Map<String, dynamic>>> getProductsPaginated(
    int limit,
    int offset,
  ) async {
    final res = await supabase
        .from("menu")
        .select()
        .range(offset, offset + limit - 1);
    return List<Map<String, dynamic>>.from(res);
  }

  /// 🔥 فلترة حسب الفئة (محسنة)
  static Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category,
  ) async {
    if (_productsCache.isEmpty) {
      await getProducts();
    }

    final lowerCategory = category.toLowerCase().trim();

    return _productsCache.where((item) {
      return (item['category'] ?? "").toString().toLowerCase().contains(
        lowerCategory,
      );
    }).toList();
  }

  /// 🔥 العروض (مع كاش)
  static Future<List<Map<String, dynamic>>> getOffers() async {
    if (_offersCache.isNotEmpty) return _offersCache;

    final res = await supabase.from("offers").select().eq("active", true);
    _offersCache = List<Map<String, dynamic>>.from(res);
    return _offersCache;
  }

  /// 🧠 تحديث الكاش (لو بدك Refresh)
  static Future<void> refreshData() async {
    _productsCache.clear();
    _offersCache.clear();
    try {
      await Future.wait([getProducts(), getOffers()]);
    } catch (e) {
      // خطأ الشبكة، يمكن إضافة log
    }
  }
}
