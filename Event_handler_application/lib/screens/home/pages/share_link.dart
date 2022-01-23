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
                style: TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12.withOpacity(0.4),
                  helperText: ' ',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  contentPadding: EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 30,
                  ),
                  errorBorder: OutlineInputBorder(
                    gapPadding: 25,
                    borderRadius: BorderRadius.circular(50),
                    borderSide: new BorderSide(
                      color: Colors.red.shade700,
                    ),
                  ),
                  border: OutlineInputBorder(
                    gapPadding: 25,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(width: 0.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    gapPadding: 20,
                    borderRadius: BorderRadius.circular(50),
                    borderSide: new BorderSide(
                      color: Colors.red.shade700,
                      width: 2,
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: 'Enter the Link of the Event...',
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(fontSize: 16, color: Colors.white),
                  labelText: "Event Link",
                ),
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
              Align(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0),
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                        elevation: 0,
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //  shadowColor: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Go to the Event',
                            style: TextStyle(
                                color: Color(0xFF121B22), fontSize: 16),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Color(0xFF121B22),
                          ),
                        ],
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
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
