import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class ApartmentPage extends StatefulWidget {
  final Map<String, dynamic> apartment;

  const ApartmentPage({Key? key, required this.apartment}) : super(key: key);

  @override
  _ApartmentPageState createState() => _ApartmentPageState();
}

class _ApartmentPageState extends State<ApartmentPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentPageIndex = 0;
  late Timer _timer;
  late PageController _pageController;
   
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _pageController = PageController(initialPage: 0); // Specify initial page
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentPageIndex =
           (_currentPageIndex + 1) % widget.apartment['pictureUrls'].length as int;

        _pageController.animateToPage(_currentPageIndex,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> pictureUrls = widget.apartment['pictureUrls'].cast<String>();

    return GestureDetector(
      onTap: () {
        // Handle tap event
      },
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: 1, // Change opacity from 0 to 1
        child: Card(
          elevation: 8.0,
          margin: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            transform:
                Matrix4.identity(), // Apply your desired transformation here
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PageView.builder(
                    itemCount: pictureUrls.length,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16.0)),
                        child: Image.network(
                          pictureUrls[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.apartment['name'],
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            widget.apartment['location'],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAnimatedIcon(
                              icon: Icons.square_foot,
                              text: '${widget.apartment['space']} sqft'),
                          _buildAnimatedIcon(
                              icon: Icons.king_bed,
                              text: '${widget.apartment['beds']} Beds'),
                          _buildAnimatedIcon(
                              icon: Icons.attach_money,
                              text: '\$${widget.apartment['price']}'),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.phone,
                            text: 'Call',
                            onPressed: () {
                              _makePhoneCall(widget.apartment['phoneNumber']);
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.message,
                            text: 'Message',
                            onPressed: () {
                              _sendMessage(widget.apartment['phoneNumber']);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(pictureUrls.length),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon({required IconData icon, required String text}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 32.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        margin: EdgeInsets.only(top: 50.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            elevation: 0,
            backgroundColor: Colors.black,
          ),
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          label: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _timer.cancel();
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Show a snackbar or dialog to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Could not make the phone call. Please try again later.'),
        ),
      );
    }
  }

  void _sendMessage(String recipient) async {
    final url = 'sms:$recipient';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Show a snackbar or dialog to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Could not send the message. Please try again later.'),
        ),
      );
    }
  }

  List<Widget> _buildPageIndicator(int pageCount) {
    List<Widget> indicators = [];
    for (int i = 0; i < pageCount; i++) {
      indicators.add(i == _currentPageIndex
          ? _indicator(true)
          : _indicator(false));
    }
    return indicators;
  }

  Widget _indicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.grey,
      ),
    );
  }
}
