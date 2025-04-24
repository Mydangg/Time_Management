import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_management/proflie/editProflie.dart';
import 'package:time_management/proflie/theme.dart';
import 'package:provider/provider.dart';

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
        final doc =
            await FirebaseFirestore.instance
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
        final taskSnapshot =
            await FirebaseFirestore.instance
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

    return Scaffold(
      appBar: AppBar(
        title: Text("profile page".tr()),
        backgroundColor: Colors.deepPurple,
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
      backgroundColor: Colors.white,
      body:
          isLoading
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
                          backgroundImage:
                              avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage(
                                        'assets/images/app_logo.png',
                                      )
                                      as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(email, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(phone, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(height: 40, thickness: 1.2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            "total_tasks".tr(),
                            totalTasks.toString(),
                            Icons.list_alt,
                          ),
                          _buildStatCard(
                            "completed_tasks".tr(),
                            completedTasks.toString(),
                            Icons.check_circle,
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
                        title: Text("dark_mode".tr()),
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                        ),
                      ),
                      const Divider(height: 40, thickness: 1.2),
                      ListTile(
                        leading: const Icon(Icons.language, color: Colors.blue),
                        title: Text("language_settings".tr()),
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                      ),
                      const Divider(height: 40, thickness: 1.2),
                      ListTile(
                        leading: const Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                        title: Text("logout".tr()),
                        onTap: () async {
                          final shouldLogout = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("confirm logout".tr()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text("cancel".tr()),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text("confirm".tr()),
                                  ),
                                ],
                              );
                            },
                          );
                          if (shouldLogout == true) {
                            // Xử lý đăng xuất
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                         
                        },
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: Material(
        elevation: 10,
        color: Colors.white,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex:
              2, // Đặt chỉ mục của trang hiện tại (ProfilePage là trang thứ 3)
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/Schedular');
                break;
               case 2:
                Navigator.pushReplacementNamed(context, '/DashboardScreen');
               case 3:
                Navigator.pushReplacementNamed(context, '/DashboardScreen');
          
              case 4:
                Navigator.pushReplacementNamed(context, '/');
            }
          },
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.blue[200],
          items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Schedule',
                ),
               
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble),
                  label: 'AI Chat',
                ),
                 BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
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
          title: Text("language_settings".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("vietnamese".tr()),
                onTap: () {
                  context.setLocale(const Locale('vi', 'VN'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("english".tr()),
                onTap: () {
                  context.setLocale(const Locale('en', 'US'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
