import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'FavoritesPage.dart';
import 'SettingsPage.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';
import 'MyOrdersPage.dart';
import 'package:shawarma_4you/pages/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  String name = "";
  String email = "";
  String? imageUrl;
  List<Map<String, dynamic>> myOrders = [];

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user != null) {
      name = user.userMetadata?["full_name"] ?? "User";
      email = user.email ?? "";
      imageUrl =
          user.userMetadata?["avatar_url"] ?? user.userMetadata?["picture"];
      loadMyOrders();
    }
  }

  // -------------------- Load My Orders --------------------
  Future<void> loadMyOrders() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('user_orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    setState(() {
      myOrders = List<Map<String, dynamic>>.from(data);
    });
  }

  void updateNameLocally(String newName) {
    setState(() => name = newName);
    final user = supabase.auth.currentUser;
    if (user != null) {
      supabase.from("users").update({"name": newName}).eq("id", user.id);
    }
  }

  void showEditDialog() {
    final controller = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("تعديل الاسم"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "ادخل الاسم الجديد",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              updateNameLocally(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // HEADER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[850],
                  backgroundImage: imageUrl != null
                      ? CachedNetworkImageProvider(imageUrl!)
                      : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: showEditDialog,
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // MENU
          Expanded(
            child: ListView(
              children: [
                // طلباتي الحالية
                menuItem(
                  icon: Icons.shopping_bag,
                  title: AppStrings.of(context).myCurrentOrders,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyOrdersPage()),
                    );
                  },
                ),
                menuItem(
                  icon: Icons.favorite,
                  title: AppStrings.of(context).favorites,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    );
                  },
                ),
                menuItem(
                  icon: Icons.settings,
                  title: AppStrings.of(context).settings,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                ),
                menuItem(
                  icon: Icons.support_agent,
                  title: AppStrings.of(context).support,
                  color: Colors.purple,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text(AppStrings.of(context).support),
                        content: Text(AppStrings.of(context).contactUs),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                menuItem(
                  icon: Icons.logout,
                  title: AppStrings.of(context).logout,
                  color: Colors.red,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text(AppStrings.of(context).confirmLogout),
                        content: Text(
                          AppStrings.of(context).logoutConfirmation,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppStrings.of(context).no),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppStrings.of(context).yes),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await supabase.auth.signOut();

                      // التعديل هنا: نذهب مباشرة لصفحة تسجيل الدخول
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(),
                        ), // ضع هنا صفحة تسجيل الدخول
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
