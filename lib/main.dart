import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import './screens/home_screen.dart';
import './screens/profile_settings_screen.dart';
import './screens/add_apartment_screen.dart';
import './screens/signup_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      initialRoute: '/login', // Set the initial route to the login screen
      routes: {
        '/login': (context) =>
            LoginScreen(), // Define the route for the login screen
        '/home': (context) =>
            HomeScreen(), // Define the route for the home screen
        // Add other routes as needed
        '/settings' : (context) => 
        ProfileSettingsScreen(),
        '/signup' :(context) => 
        SignupScreen(),
        '/add' :(context) => 
        AddApartmentScreen()
      },
    );
  }
}
