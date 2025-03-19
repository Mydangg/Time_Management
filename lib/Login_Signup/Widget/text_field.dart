import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;
  final FormFieldValidator<String>? validator;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false, 
    required this.hintText, 
    required this.icon, 
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        obscureText: isPass,
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hintText,
          errorStyle: const TextStyle(color: Colors.red),
          hintStyle: const TextStyle(
            color: Color(0xFF778899),
            fontSize: 18,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.black45,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 15,
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none, 
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: validator ?? (value) {
          // Email validation logic
          if (value == null || value.isEmpty) {
            return 'Email is required';
          } else if (!value.contains('@')) {
            return 'Please enter a valid email with "@"';
          }
          return null;
        }, 
      ),
    );
  }
}
