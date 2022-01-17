import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Share_Link extends StatefulWidget {
  Share_Link({Key? key}) : super(key: key);
  _ShareLinkState createState() => _ShareLinkState();
}

class _ShareLinkState extends State<Share_Link> {
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  String eventId = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: ListView(
              padding: EdgeInsets.only(top: 250, left: 25, right: 25),
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Event Link'),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Event Link is required';
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      eventId = value.trim();
                    });
                  },
                ),
                SizedBox(height: 20),
                FutureBuilder(
                    future: DatabaseService(_authService.getCurrentUser()!.uid,
                            FirebaseFirestore.instance)
                        .getEventByid(eventId),
                    initialData: "Loading text..",
                    builder:
                        (BuildContext context, AsyncSnapshot<Object> event) {
                      return ElevatedButton(
                          child: Text('Go to event'),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventScreen(
                                        event: event.data as Event,
                                      )),
                            );
                          });
                    }),
              ]),
        ),
      ),
    );
  }
}
