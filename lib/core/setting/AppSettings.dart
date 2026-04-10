import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static bool isDark = false;
  static bool isArabic = true;

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('isDark') ?? false;
    isArabic = prefs.getBool('isArabic') ?? true;
  }

  static Future<void> setDark(bool value) async {
    isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
  }

  static Future<void> setArabic(bool value) async {
    isArabic = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isArabic', value);
  }
}
