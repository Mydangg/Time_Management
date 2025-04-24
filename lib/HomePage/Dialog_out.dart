import 'package:flutter/material.dart';

class ShowDialogOut extends StatelessWidget {
  const ShowDialogOut({super.key});

  void _logout() {
    // TODO: Viết logic logout ở đây, ví dụ FirebaseAuth.instance.signOut()
    print("Đã đăng xuất");
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Huỷ
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  _logout(); // Xử lý logout
                },
                child: const Text("Log out"),
              ),
            ],
          ),
        );
      },
      child: const Text("Show Logout Dialog"),
    );
  }
}
