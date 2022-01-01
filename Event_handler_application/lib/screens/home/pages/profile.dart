import 'package:event_handler/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final AuthService auth= AuthService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body:  Center(
          child: ElevatedButton(
            child: Text('log out'),
            onPressed: ()async { 
              await auth.signOut();
            })),
        ),
      );
  }
}
