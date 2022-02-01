import 'dart:async';

import 'package:event_handler/screens/authenticate/tutorial.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String _StartedTimes = '';

  // Future<int> _getIntFromSharedPref() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final startUpNumber = prefs.getInt('startUpNumber');
  // }

  @override
  void initState() {
    super.initState();
    _incrementStartup();
    Timer(
      Duration(seconds: 7),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                (int.parse(_StartedTimes) == 0 || int.parse(_StartedTimes) == 1)
                    ? Tutorial(authServices: AuthService(FirebaseAuth.instance))
                    : Wrapper()),
      ),
    );
  }

  Future<int> _getIntFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final startupNumber = prefs.getInt('startupNumber');
    if (startupNumber == null) {
      return 0;
    }
    return startupNumber;
  }

  Future<void> _incrementStartup() async {
    final prefs = await SharedPreferences.getInstance();

    int lastStartupNumber = await _getIntFromSharedPref();
    int currentStartupNumber = ++lastStartupNumber;

    await prefs.setInt('startupNumber', currentStartupNumber);

    setState(() => _StartedTimes = '$currentStartupNumber');

    // Reset only if you want to
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF121B22),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              'assets/bap.png',
              height: 300,
              width: 300,
            ),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
