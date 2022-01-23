import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyEvents extends StatelessWidget {
  MyEvents({Key? key, required this.databaseService, required this.authService})
      : super(key: key);
  final DatabaseService databaseService;
  final AuthService authService;
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = databaseService.getEvents();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Events',
        ),
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: Color(0xFF121B22),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                    stream: events,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('loading');
                      }
                      final data = snapshot.requireData;
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: data.size,
                          itemBuilder: (context, index) {
                            for (var i = 0;
                                i < data.docs[index]['partecipants'].length;
                                i++) {
                              if (data.docs[index]['partecipants'][i] ==
                                  authService.getCurrentUser()!.uid) {
                                return Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.black12),
                                    margin: EdgeInsets.all(10),
                                    child: ListView(
                                      padding: EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${data.docs[index]['name']}'),
                                            Text('${data.docs[index]['date']}'),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                            '${data.docs[index]['placeName']}'),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'event Type: ${data.docs[index]['eventType']}'),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Event event = Event(
                                                      data.docs[index]
                                                          ['manager'],
                                                      data.docs[index]['name'],
                                                      data.docs[index]
                                                          ['urlImage'],
                                                      data.docs[index]
                                                          ['description'],
                                                      data.docs[index]
                                                          ['latitude'],
                                                      data.docs[index]
                                                          ['longitude'],
                                                      data.docs[index]
                                                          ['placeName'],
                                                      data.docs[index]
                                                          ['eventType'],
                                                      data.docs[index]
                                                          ['typeOfPlace'],
                                                      data.docs[index]['date'],
                                                      data.docs[index]
                                                          ['maxPartecipants'],
                                                      data.docs[index]['price'],
                                                      data.docs[index]
                                                          ['eventId'],
                                                      List<String>.from(
                                                          data.docs[index]
                                                              ['partecipants']),
                                                      List<String>.from(
                                                          data.docs[index]
                                                              ['applicants']),
                                                      List<String>.from(
                                                          data.docs[index]
                                                              ['qrCodeList']),
                                                      data.docs[index]
                                                          ['firstFreeQrCode']);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => EventScreen(
                                                            event: event,
                                                            authService: AuthService(
                                                                FirebaseAuth
                                                                    .instance),
                                                            databaseService: DatabaseService(
                                                                AuthService(FirebaseAuth
                                                                        .instance)
                                                                    .getCurrentUser()!
                                                                    .uid,
                                                                FirebaseFirestore
                                                                    .instance))),
                                                  );
                                                },
                                                child: Text('More info')),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ));
                              }
                            }
                            return Container();
                          });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
