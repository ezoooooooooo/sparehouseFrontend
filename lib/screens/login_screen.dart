import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_textfield.dart';
import './signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email = '';
  String _password = '';
  String _errorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  Future<void> _login() async {
  try {
    final response = await http.post(
      Uri.parse(
          '$BASE_URL/api/auth/login'), // Replace with your login endpoint
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': _email,
        'password': _password,
      }),
    );

    if (response.statusCode == 200) {
      final sessionId = response.headers['set-cookie']; // Get session ID from response header
      if (sessionId != null) {
        // Store the session ID for future requests
        await _secureStorage.write(key: 'connect.sid', value: sessionId);
        
        // Login successful, handle navigation to the next screen
        _showSnackBar('Login successful', Colors.green);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle missing session ID
        _showSnackBar('Session ID not found', Colors.red);
      }
    } else {
      // Handle login failure
      _showSnackBar('Login failed: ${response.body}', Colors.red);
    }
  } catch (e) {
    // Handle network errors or other exceptions
    _showSnackBar('Error occurred: $e', Colors.red);
  }
}

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_errorMessage.isNotEmpty) _buildSnackBar(),
                SizedBox(height: 20.0),
                RoundedTextField(
                  // Use RoundedTextField here
                  hintText: 'Email',
                  icon: Icons.email,
                  isPassword: false,
                  controller: _emailController,
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                RoundedTextField(
                  // Use RoundedTextField here
                  hintText: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                RoundedButton(
                  onPressed: _login,
                  text: 'Login',
                  icon: Icons.login,
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Signup",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnackBar() {
    return SnackBar(
      content: Text(
        _errorMessage,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}
