import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Share_Link extends StatefulWidget {
  Share_Link({Key? key, required this.databaseService}) : super(key: key);
  DatabaseService databaseService;
  _ShareLinkState createState() => _ShareLinkState();
}

class _ShareLinkState extends State<Share_Link> {
  String eventId = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          color: Color(0xFF121B22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  future: widget.databaseService.getEventByid(eventId),
                  initialData: "Loading text..",
                  builder: (BuildContext context, AsyncSnapshot<Object> event) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 16,

                      // margin: EdgeInsets.only(
                      // left: MediaQuery.of(context).size.width / 10, right: MediaQuery.of(context).size.width / 10),

                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            'Go to the Event',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventScreen(
                                      event: event.data as Event,
                                      authService:
                                          AuthService(FirebaseAuth.instance),
                                      databaseService: DatabaseService(
                                          AuthService(FirebaseAuth.instance)
                                              .getCurrentUser()!
                                              .uid,
                                          FirebaseFirestore.instance))),
                            );
                          }),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
