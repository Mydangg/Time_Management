import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Login_Signup/Screen/login.dart';

class DialogService {
  // Hiển thị dialog xác nhận logout
  Future<void> showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              _logout(context);       // Gọi hàm logout
            },
            child: const Text("Log out"),
          ),
        ],
      ),
    );
  }

  // Hàm xử lý đăng xuất
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
