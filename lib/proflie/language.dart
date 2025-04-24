import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("language_settings".tr()), // Sử dụng key từ file JSON
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("vietnamese".tr()), // Hiển thị "Tiếng Việt"
            onTap: () {
              context.setLocale(const Locale('vi', 'VN')); // Chuyển sang Tiếng Việt
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ngôn ngữ đã chuyển sang Tiếng Việt")),
              );
            },
          ),
          ListTile(
            title: Text("english".tr()), // Hiển thị "English"
            onTap: () {
              context.setLocale(const Locale('en', 'US')); // Chuyển sang Tiếng Anh
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Language switched to English")),
              );
            },
          ),
        ],
      ),
    );
  }
}