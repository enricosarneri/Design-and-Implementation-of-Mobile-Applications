import 'package:event_handler/screens/authenticate/authenticate.dart';
import 'package:event_handler/screens/home/application_block.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:event_handler/screens/home/google_map_screen.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final AuthService _authService = AuthService();

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
              onPressed: () async {
                await _authService.signOut();
                //to be changed
              },
              icon: Icon(Icons.person),
              label: Text('Logout'))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapScreen(),
          ),
        ),
        tooltip: 'GoogleMap',
        child: Icon(Icons.pin_drop_outlined),
      ),
    );
  }
}
