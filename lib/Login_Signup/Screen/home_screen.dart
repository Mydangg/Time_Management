// import 'package:firebase_dart/auth.dart';
import 'package:flutter/material.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/Login_Signup/Widget/button.dart';
import 'package:time_management/Login_with_Google/google_auth.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Congratulation\nYou have Succefully Login",
              textAlign: TextAlign.center, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ), 
            ),
            MyButton(
              onTab: () async{
              await FirebaseServices().googleSignOut();
                // await AuthServices().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context)=> const LoginScreen(),
                  ),
                );
            }, 
            text: "Log Out"),
            // Image.network("${FirebaseAuth.instance.currentUser!.photoURL}"),
            // Text("${FirebaseAuth.instance.currentUser!.email}"),
            // Text("${FirebaseAuth.instance.currentUser!.displayName}")
          ],
        ),
      ),
    );
  }
}