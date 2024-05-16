import 'package:flutter/material.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_textfield.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  Future<void> _updateName() async {
    try {
      final sessionId = await _secureStorage.read(key: 'session_id');
      if (sessionId != null) {
        final response = await http.put(
          Uri.parse('$BASE_URL/api/user/name'),
          headers: <String, String>{
            'Cookie': sessionId,
          },
          body: jsonEncode(<String, String>{
            'name': _nameController.text,
          }),
        );
        if (response.statusCode == 200) {
          // Update successful
          _showSnackBar('Name updated successfully', Colors.green);
          Navigator.pop(context, true); 
        } else {
          // Handle other errors
          _showSnackBar('Failed to update name: ${response.statusCode}', Colors.red);
        }
      } else {
        _showSnackBar('Session ID not found', Colors.red);
      }
    } catch (e) {
      // Handle network errors or other exceptions
      _showSnackBar('Error occurred: $e', Colors.red);
    }
  }

  Future<void> _updatePassword() async {
    try {
      final sessionId = await _secureStorage.read(key: 'session_id');
      if (sessionId != null) {
        final response = await http.put(
          Uri.parse('$BASE_URL/api/user/password'),
          headers: <String, String>{
            'Cookie': sessionId,
          },
          body: jsonEncode(<String, String>{
            'oldPassword': _oldPasswordController.text,
            'newPassword': _newPasswordController.text,
          }),
        );
        if (response.statusCode == 200) {
          // Update successful
          _showSnackBar('Password updated successfully', Colors.green);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Password Updated'),
                content: Text('Your password has been updated successfully.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Log Out'),
                    onPressed: () {
                      _logout();
                    },
                  ),
                  TextButton(
                    child: Text('Continue'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Handle other errors
          _showSnackBar('Failed to update password: ${response.statusCode}', Colors.red);
        }
      } else {
        _showSnackBar('Session ID not found', Colors.red);
      }
    } catch (e) {
      // Handle network errors or other exceptions
      _showSnackBar('Error occurred: $e', Colors.red);
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final sessionId = await _secureStorage.read(key: 'session_id');
      if (sessionId != null) {
        final response = await http.delete(
          Uri.parse('$BASE_URL/api/user/delete'),
          headers: <String, String>{
            'Cookie': sessionId,
          },
        );
        if (response.statusCode == 200) {
          // Deletion successful
          _showSnackBar('Account deleted successfully', Colors.green);
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Handle other errors
          _showSnackBar('Failed to delete account: ${response.statusCode}', Colors.red);
        }
      } else {
        _showSnackBar('Session ID not found', Colors.red);
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
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _logout() async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/auth/logout'),
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Profile Settings',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RoundedTextField(
                          controller: _nameController,
                          hintText: 'Enter your name',
                          isPassword: false,
                          icon: Icons.person,
                        ),
                        SizedBox(height: 20.0),
                        RoundedButton(
                          text: 'Update Name',
                          onPressed: _updateName,
                          icon: Icons.person,
                        ),
                        SizedBox(height: 40.0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RoundedTextField(
                          controller: _oldPasswordController,
                          hintText: 'Old Password',
                          isPassword: true,
                          icon: Icons.lock,
                        ),
                        RoundedTextField(
                          controller: _newPasswordController,
                          hintText: 'New Password',
                          isPassword: true,
                          icon: Icons.lock,
                        ),
                        SizedBox(height: 20.0),
                        RoundedButton(
                          text: 'Update Password',
                          onPressed: _updatePassword,
                          icon: Icons.lock,
                        ),
                        SizedBox(height: 40.0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RoundedButton(
                          text: 'Delete My Account',
                          onPressed: _deleteAccount,
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
