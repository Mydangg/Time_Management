import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_management/proflie/editProflie.dart';
import 'package:time_management/proflie/theme.dart';
import 'package:provider/provider.dart';

import '../HomePage/Dialog_out.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String phone = '';
  String avatarUrl = '';
  String bio = '';
  int totalTasks = 0;
  int completedTasks = 0;
  bool isLoading = true;

  DialogService showDialogOut = DialogService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTaskStats();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            name = doc['name'] ?? '';
            email = doc['email'] ?? '';
            phone = doc['phone'] ?? '';
            avatarUrl = doc['avatarUrl'] ?? '';
            bio = doc['bio'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error loading user info: $e");
      }
    }
  }

  Future<void> _loadTaskStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final taskSnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('createById', isEqualTo: user.uid)
            .get();

        final completed =
            taskSnapshot.docs.where((doc) => doc['completed'] == true).length;

        setState(() {
          totalTasks = taskSnapshot.size;
          completedTasks = completed;
        });
      } catch (e) {
        print("Error loading task stats: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(uid: user.uid),
                  ),
                ).then((_) {
                  _loadUserInfo();
                  _loadTaskStats(); // reload lại stats sau khi chỉnh sửa
                });
              }
            },
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await _loadUserInfo();
          await _loadTaskStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/images/app_logo.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                bio,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const Divider(height: 40, thickness: 1.2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                      "Total Tasks".tr(),
                      totalTasks.toString(),
                      Icons.list_alt
                  ),
                  _buildStatCard(
                      "Completed Tasks".tr(),
                      completedTasks.toString(),
                      Icons.check_circle
                  ),
                ],
              ),
              const Divider(height: 40, thickness: 1.2),
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: Text("Dark Mode".tr()),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),
              const Divider(height: 40, thickness: 1.2),
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text("Language settings".tr()),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
              const Divider(height: 40, thickness: 1.2),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: Text("Logout".tr()),
                onTap: () {
                  showDialogOut.showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Language Settings".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  context.setLocale(const Locale('en', 'US'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text("Tiếng Việt"),
                onTap: () {
                  context.setLocale(const Locale('vi', 'VN'));
                  Navigator.of(context).pop();
                  print('Ngôn ngữ hiện tại: ${context.locale}');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
