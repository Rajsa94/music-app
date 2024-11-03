import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    _animation = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate to home screen after delay
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color as needed
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center the children horizontally
          children: [
            SlideTransition(
              position: _animation,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Minimize height to center contents
                children: [
                  // Add your logo image here
                  Image.asset(
                    'assets/images/rathore-logo.png', // Update this with the correct path to your logo
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                  SizedBox(height: 20),
                  // Add your app title here
                  Text(
                    "Rathore Music App",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
