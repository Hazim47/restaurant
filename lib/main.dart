import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/auth/login_page.dart';
import 'pages/main/main_page.dart';
import 'managers/cart_manager.dart';
import 'package:shawarma_4you/core/setting/AppSettings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nvctbcqazlhagmvnubtl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52Y3RiY3FhemxoYWdtdm51YnRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4NDI4NzMsImV4cCI6MjA4ODQxODg3M30.6YdjdANI-wnO58lVzyJ6XxNom8kVOIqtWU6TpVKHJoM',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      final user = session.user;

      // تحديث بيانات المستخدم في قاعدة البيانات
      await Supabase.instance.client.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'name':
            user.userMetadata?['full_name'] ??
            (user.email ?? "user").split("@").first,
        'avatar_url':
            user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
      });

      // 🔹 إعادة التوجيه للهوم مباشرة
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    }
  });

  await CartManager.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void refreshApp() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Shawarma 4You',
      theme: AppSettings.isDark ? ThemeData.dark() : ThemeData.light(),
      locale: AppSettings.isArabic ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashPage(),
    );
  }
}

/// 🔹 صفحة سبلاش سلسة
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 🔹 حركة تكبير بسيطة للسبلاش
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // 🔹 تحقق من حالة المصادقة بعد 1 ثانية
    Future.delayed(const Duration(seconds: 1), () {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Text(
            'Shawarma 4You',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.amber : Colors.amber,
            ),
          ),
        ),
      ),
    );
  }
}
