import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../menu/menu_page.dart';
import '../cart/cart_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/custom_bottom_navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static _MainPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainPageState>();
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    MenuPage(),
    CartPage(),
  ]; // ❌ حذفنا البروفايل من هنا

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      endDrawer: const ProfilePage(), // 🔥 البروفايل من الجنب

      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 3) {
            // 🔥 فتح البروفايل من الجنب
            scaffoldKey.currentState?.openEndDrawer();
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
