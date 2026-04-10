import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesManager {
  static final supabase = Supabase.instance.client;
  static Set<int> favoriteIds = {};

  static Future<void> loadFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id);

    favoriteIds = res.map<int>((e) => e['product']['id'] as int).toSet();
  }

  static bool isFavorite(int productId) => favoriteIds.contains(productId);

  static Future<void> toggleFavorite(Map product) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final productId = product['id'] as int;

    if (favoriteIds.contains(productId)) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('product->>id', productId.toString());
      favoriteIds.remove(productId);
    } else {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'product': product,
      });
      favoriteIds.add(productId);
    }
  }
}
