import 'dart:async';

import 'package:event_handler/screens/authenticate/tutorial.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 7),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Tutorial(authServices: AuthService(FirebaseAuth.instance))),
      ),
    );
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
