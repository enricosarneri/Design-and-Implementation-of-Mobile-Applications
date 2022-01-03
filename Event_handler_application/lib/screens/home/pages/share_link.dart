import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:flutter/material.dart';

class Share_Link extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Center(
            child: ElevatedButton( 
            child: Text('Go to event'),
            onPressed: ()async {
               Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Wrapper()),//EventScreen(event: event,)),
                  );
                }
            )
          ),
        ),
      ),
    );
  }
}
