import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_management/Login_Signup/Widget/snack_bar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 35),
        child: Align(
          alignment: Alignment.centerRight, 
          child: InkWell(
            onTap: (){
              myDialogBox(context);
            },
            child: Text("Forgot Password?", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );
  }


void myDialogBox(BuildContext context){
  showDialog(
    context: context, 
    builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Text("Forgot Your Password", 
                    style:TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                    ) ,
                  ),
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
               TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: "Enter the Email", 
                  hintText: "abc@gmail.com",
                ),
              ),
               const SizedBox(height: 20),
               ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: ()async{
                  await auth
                    .sendPasswordResetEmail(email: emailController.text)
                    .then((value){
                      showSnackBar(context, 
                      "We have send you the reser password link ti your email id, Please check it");
                    } )
                    .onError((error, stackTrace) {
                      showSnackBar(context, error.toString());
                    });
                    Navigator.pop(context);
                    emailController.clear();
                }, 
                child: const Text("Send", 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, 
                  color: Colors.white,
                  ),
                )
              )
            ],
          ),
        ),
      );
    }
  );
}
}