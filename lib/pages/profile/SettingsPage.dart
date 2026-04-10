import 'package:flutter/material.dart';
import 'package:shawarma_4you/core/language/AppStrings.dart';
import 'package:shawarma_4you/main.dart';
import 'package:shawarma_4you/core/setting/AppSettings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          AppStrings.of(context).settings,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardItem(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            value: AppSettings.isDark,
            onChanged: (v) async {
              await AppSettings.setDark(v); // حفظ دائم
              setState(() {});
              MyApp.of(context)?.refreshApp();
            },
          ),
          const SizedBox(height: 20),
          _cardItem(
            icon: Icons.language,
            title: "Language / اللغة",
            value: AppSettings.isArabic,
            onChanged: (v) async {
              await AppSettings.setArabic(v); // حفظ دائم
              setState(() {});
              MyApp.of(context)?.refreshApp();
            },
          ),
        ],
      ),
    );
  }

  Widget _cardItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900.withOpacity(0.8),
            Colors.grey.shade800.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.blueAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Switch(
                  value: value,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => onChanged(v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
