import 'package:event_handler/screens/authenticate/authenticate.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final AuthService _authService= AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Event handler'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async{
              await _authService.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Authenticate()));
              //to be changed
            },
            icon: Icon(Icons.person),
            label: Text('logout'))
        ],
      ),
    );
  }
}