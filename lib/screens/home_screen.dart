import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../widgets/custom_search.dart';
import '../apartment.dart';
import './add_apartment_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './profile_settings_screen.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _apartments = [];
 String _userName = ''; 
  String _userEmail = ''; 



  @override
  void initState() {
    super.initState();
     _getUserDetails();
    _fetchApartments();
    
  }
  Future<void> _getUserDetails() async {
  final _secureStorage = FlutterSecureStorage();

  try {
    final sessionId = await _secureStorage.read(key: 'connect.sid');
    if (sessionId != null) {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/user/details'),
        headers: <String, String>{
          'Cookie': sessionId, // Send session ID as a cookie
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userName = data['name'];
          _userEmail = data['email'];
        });
      } else {
        // Handle unauthorized error (401)
        if (response.statusCode == 401) {
          // Redirect the user to the login screen
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Handle other errors
          print('Failed to fetch user details: ${response.statusCode}');
        }
      }
    } else {
      // Handle missing session ID
      print('Session ID not found');
      Navigator.pushReplacementNamed(context, '/login');
    }
  } catch (e) {
    // Handle network error
    print('Failed to fetch user details: $e');
  }
}



 
  Future<void> _fetchApartments({String? location, int? beds, int? minPrice, int? maxPrice}) async {
  try {
    String url = '$BASE_URL/api/apartments';
    
    if (location != null) {
      // If location is provided, add it to the URL
      url += '/location?location=$location';
    } else if (beds != null) {
      // If beds filter is provided, add it to the URL
      url += '/beds?beds=$beds';
    } else if (minPrice != null && maxPrice != null) {
      // If price range filter is provided, add it to the URL
      url += '/price?minPrice=$minPrice&maxPrice=$maxPrice';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _apartments = List<Map<String, dynamic>>.from(data);
      });
    } else {
      // Handle error
      print('Failed to fetch apartments: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network error
    print('Failed to fetch apartments: $e');
  }
}


Future<void> _applyFilter() async {
  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Show modal bottom sheet for filtering beds
                  Navigator.of(context).pop();
                  _applyBedsFilter();
                },
                child: Text('Filter by Beds'),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Show modal bottom sheet for filtering price range
                  Navigator.of(context).pop();
                  _applyPriceFilter();
                },
                child: Text('Filter by Price Range'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _applyBedsFilter() async {
  int? selectedBeds; // Variable to hold the selected number of beds

  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of beds',
                ),
                onChanged: (value) {
                  // Parse the value entered by the user
                  selectedBeds = int.tryParse(value);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Apply filter for beds
                  _fetchApartments(beds: selectedBeds);
                  Navigator.of(context).pop();
                },
                child: Text('Apply'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _applyPriceFilter() async {
  int? minPrice; // Variable to hold the minimum price
  int? maxPrice; // Variable to hold the maximum price

  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter min price',
                ),
                onChanged: (value) {
                  // Parse the value entered by the user
                  minPrice = int.tryParse(value);
                },
              ),
              SizedBox(height: 10.0),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter max price',
                ),
                onChanged: (value) {
                  // Parse the value entered by the user
                  maxPrice = int.tryParse(value);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Apply filter for price range
                  _fetchApartments(minPrice: minPrice, maxPrice: maxPrice);
                  Navigator.of(context).pop();
                },
                child: Text('Apply'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
Future<void> _logout() async {
  try {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/auth/logout'),
    );
    if (response.statusCode == 200) {
      // Navigate back to login screen
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Handle error
      print('Failed to logout: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network error
    print('Failed to logout: $e');
  }
}
Future<void> _navigateToProfileSettings() async {
  final bool? result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfileSettingsScreen()),
  );

  // Check if the result indicates that the name was updated
  if (result == true) {
    // Fetch the updated user details
    _getUserDetails();
  }
}



 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 70.0),
                  child: CustomSearchBar(
                    onSearch: (location) {
                      _fetchApartments(location: location);
                    },
                    onClear: () {
                      _fetchApartments();
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _apartments.length,
                    itemBuilder: (context, index) {
                      final apartment = _apartments[index];
                      return ApartmentPage(apartment: apartment);
                    },
                  ),
                ),
              ],
            ),
          ),
Positioned(
  top: 20.0,
  right: 20.0,
  child: GestureDetector(
    onTap: () {
      // Handle tap to show popup menu
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          MediaQuery.of(context).size.width - 120,
          100,
          0,
          0,
        ), // Adjusted position
        items: [
          PopupMenuItem(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $_userName',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              title: Text(
                'Profile Settings',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
              await _navigateToProfileSettings();
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
          ),
        ],
      );
    },
    child: CircleAvatar(
      // You can customize the appearance of the avatar here
      backgroundColor: Colors.blue,
      child: Text(
        _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
),




          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              backgroundColor: Colors.blue,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.filter_list),
                  backgroundColor: Colors.blue,
                  onTap: () {
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0, // Align FAB to the right
            child: FloatingActionButton(
              onPressed: () async {
                // Navigate to AddApartmentScreen and wait for result
                final bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddApartmentScreen()),
                );

                // Check if the result is true, indicating an apartment was added
                if (result == true) {
                  // Fetch the updated list of apartments
                  _fetchApartments();
                }
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue, // Same color as the filter button
            ),
          ),
        ],
      ),
    );
  }
}


