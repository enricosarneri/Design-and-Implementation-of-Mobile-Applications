
import 'package:event_handler/screens/events/create_event.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:event_handler/screens/home/google_map_screen.dart';

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
              icon: const Icon(Icons.person),
              label: const Text('Logout'))
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
        child: const Icon(Icons.pin_drop_outlined),
      ),
      body: Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
        child: ElevatedButton(
          child: const Icon(Icons.add_location_alt_outlined),
          onPressed: () => 
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Create_Event(),
            ),
        ),)
      ,),
    );
  }
}
