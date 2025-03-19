import 'package:flutter/material.dart';
import 'package:time_management/Login_Signup/Screen/Home_screen.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/Login_Signup/Services/authentication.dart';
import 'package:time_management/Login_Signup/Widget/snack_bar.dart';

import '../Widget/button.dart';
import '../Widget/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();  // Add form key
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signUpUser() async {
    if (_formKey.currentState!.validate()) { // Validate form before signup
      String res = await AuthServices().signUpUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      );
      if (res == "success") {
        setState(() {
          isLoading = true;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, res);
      }
    }
  }

  // Function to validate email format
  String? validateEmail(String? value) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  // Function to validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Function to validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Form( // Wrap with Form
            key: _formKey, // Assign the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: height / 2.6,
                  child: Image.asset("images/sign_up.png"),
                ),
                TextFieldInput(
                  textEditingController: nameController,
                  hintText: "Enter your name",
                  icon: Icons.person,
                  validator: validateName,
                ),
                TextFieldInput(
                  textEditingController: emailController,
                  hintText: "Enter your email",
                  icon: Icons.email,
                  // Use the email validator
                  validator: validateEmail,
                ),
                TextFieldInput(
                  textEditingController: passwordController,
                  hintText: "Enter your password",
                  isPass: true,
                  icon: Icons.lock,
                  validator: validatePassword,
                ),
                MyButton(onTab: signUpUser, text: "Sign Up"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        " Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
