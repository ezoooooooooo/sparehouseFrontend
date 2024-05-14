import 'package:flutter/material.dart';

class RoundedTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType? keyboardType; // Make keyboardType optional
  final ValueChanged<String>? onChanged;

  const RoundedTextField({
    required this.hintText,
    required this.icon,
    required this.isPassword,
    required this.controller,
    this.keyboardType, // Make keyboardType optional
    this.onChanged,
  });

  @override
  _RoundedTextFieldState createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              obscureText: widget.isPassword && !isPasswordVisible,
              style: TextStyle(color: Colors.white),
              keyboardType: widget.keyboardType, // Use keyboardType if provided
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.isPassword)
            IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
        ],
      ),
    );
  }
}
