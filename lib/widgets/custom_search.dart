import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String)? onSearch; // Define the onSearch callback
   final VoidCallback? onClear; // Define the onClear callback
  CustomSearchBar({Key? key, this.onSearch, this.onClear}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.blue, // Primary color
        boxShadow: [
          BoxShadow(
            color:
                Colors.blue.withOpacity(0.5), // Adjust shadow color and opacity
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          onTap: () {
            // Keep the onTap function as is for now
            if (onSearch != null) {
              onSearch!('');
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.blue
                  .withOpacity(0.8), // Adjust pulse color and opacity
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search location', // Placeholder text
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none, // Remove the border
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        // Pass the typed value to the onSearch callback
                        if (onSearch != null) {
                          onSearch!(value);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      // Call the onClear callback when the clear button is pressed
                      if (onClear != null) {
                        onClear!();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
