import 'package:flutter/material.dart';
import 'package:time_management/Login_Signup/Screen/sign_up.dart';
import 'package:time_management/Login_Signup/Widget/button.dart';
import 'package:time_management/Login_Signup/Widget/text_field.dart';
import 'package:time_management/Login_with_Google/google_auth.dart';
import 'package:time_management/Password_Forgot/forgot_password.dart';

import '../Services/authentication.dart';
import '../Widget/snack_bar.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 

  bool isLoading = false;

   void dispose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
  
  void loginUser() async{
    if (_formKey.currentState!.validate()) { // Validate form before signup
      String res = await AuthServices().loginUser(
        email: emailController.text,
        password: passwordController.text,

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


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
  
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: height/2.7, 
                    child: Image.asset("images/login.png"),
                    ),
                  TextFieldInput(
                    textEditingController: emailController, 
                    hintText: "Enter your email", 
                    icon: Icons.email,
                    validator: validateEmail,
                  ),
                    TextFieldInput(
                    textEditingController: passwordController, 
                    hintText: "Enter your password", 
                    isPass: true,
                    icon: Icons.lock,
                    validator: validatePassword,
                  ),
                      const SizedBox(height: 15),
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 35),
                  //   child: Align(
                  //     alignment: Alignment.centerRight,
                  //     child: Text("Forgot Password?", 
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.bold, 
                  //         fontSize: 16, 
                  //         color: Colors.blue,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                    const ForgotPassword(),
                      const SizedBox(height: 10),
                  MyButton(
                    onTab: loginUser, 
                    text: "Login"
                  ),
              
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: Container(
                        height: 1,
                        color: Colors.black45,
                      ),
                    ),
                      const Text(" or "),
                      Expanded(
                        child: Container(
                          height: 1, 
                          color: Colors.black45,
                        ),
                      )
                    ],
                  ),
                      const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10), 
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 147, 174, 188)),
                      onPressed: () async{
                          await FirebaseServices().signInWithGoogle();
                          Navigator.pushReplacement(
                            context, MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                      }, 
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.asset("images/login_gg.png",
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("Continue with Google", 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 20,
                            color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?", 
                        style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(" Sign Up", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
            ),
          ),
      )),
    );
  }
} 
