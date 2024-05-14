import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/rounded_textfield.dart';
import '../widgets/rounded_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _errorMessage = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

 Future<void> _signup() async {
  try {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/auth/signup'), 
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': _name,
        'email': _email,
        'password': _password,
      }),
    );

    if (response.statusCode == 201) {
      final sessionId = response.headers['set-cookie']; // Get session ID from response header
      if (sessionId != null) {
        // Store the session ID for future requests
        await _secureStorage.write(key: 'connect.sid', value: sessionId);
        
        // Signup successful, handle navigation to the home screen
        _showSnackBar('Signup successful', Colors.green);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle missing session ID
        _showSnackBar('Session ID not found', Colors.red);
      }
    } else {
      // Handle signup failure
      _showSnackBar('Signup failed: ${response.body}', Colors.red);
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
          // Background image or color
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
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
                  hintText: 'Name',
                  icon: Icons.person,
                  isPassword: false,
                  controller: _nameController,
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                RoundedTextField(
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
                  onPressed: _signup,
                  text: 'Signup',
                  icon: Icons.person_add,
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
