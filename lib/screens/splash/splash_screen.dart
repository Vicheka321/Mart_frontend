import 'package:flutter/material.dart';
import 'package:mart_frontend/screens/main/main_screen.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "My Mart App",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}