import 'package:flutter/material.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/Login_Signup/Widget/button.dart';
import 'package:time_management/Login_with_Google/google_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

//Hàm chuyển trang
   void _onItemTapped(int index) {

    //Đây là cái để ấn vô icon sẽ nổi lên
        setState(() {
          selectedIndex = index;
          });

     //Đây là cái để chuyển trang
    switch (index) {
  //     case 0:
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page1()));
  //       break;
  //     case 1:
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page2()));
  //       break;
  //     case 2:
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page3()));
  //       break;
  //     case 3:
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page4()));
  //       break;
      case 4:
        _showLogoutDialog(); // Gọi hàm xác nhận logout
        break;
    }
   }

//Thông báo xác nhận
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Huỷ
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              _logout(); // Xử lý logout
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }


  //Hàm logout
  // xử lý đăng xuất ở đây (xoá token, điều hướng về login...)
  void _logout() async {
    await FirebaseServices().googleSignOut();
    // await AuthServices().signOut();

    //Điều hướng về login
    Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const LoginScreen()
    )); // điều hướng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'My Tasks',
          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue[800]),
      ),
      body: Center(
        child: Text(
          'Danh sách đang trống',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped, //Gọi hàm để chuyển trang
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.blue[200],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Nhiệm vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Đăng xuất'),
        ],
      ),
    );
  }
}
