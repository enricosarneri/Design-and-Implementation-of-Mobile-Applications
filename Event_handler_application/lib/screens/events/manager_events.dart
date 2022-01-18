import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManagerEvents extends StatelessWidget {
  ManagerEvents(
      {Key? key, required this.databaseService, required this.authService})
      : super(key: key);
  final DatabaseService databaseService;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = databaseService.getEvents();
    return Scaffold(
      appBar: AppBar(title: Text('My events')),
      body: Padding(
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
                          if (data.docs[index]['manager'] ==
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
                                    Text('${data.docs[index]['placeName']}'),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'event Type: ${data.docs[index]['eventType']}'),
                                        ElevatedButton(
                                            onPressed: () {
                                              Event event = Event(
                                                  data.docs[index]['manager'],
                                                  data.docs[index]['name'],
                                                  data.docs[index]['urlImage'],
                                                  data.docs[index]
                                                      ['description'],
                                                  data.docs[index]['latitude'],
                                                  data.docs[index]['longitude'],
                                                  data.docs[index]['placeName'],
                                                  data.docs[index]
                                                      ['typeOfPlace'],
                                                  data.docs[index]['eventType'],
                                                  data.docs[index]['date'],
                                                  data.docs[index]
                                                      ['maxPartecipants'],
                                                  data.docs[index]['price'],
                                                  data.docs[index]['eventId'],
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
                                                            AuthService(
                                                                    FirebaseAuth
                                                                        .instance)
                                                                .getCurrentUser()!
                                                                .uid,
                                                            FirebaseFirestore
                                                                .instance))),
                                                //  Event(this.managerId, this.name, this.description, this.latitude, this.longitude, this.placeName,this.eventType,this.date, this.maxPartecipants, this.eventId, this.partecipants, this.applicants, this.qrCodes);
                                              );
                                            },
                                            child: Text('More info')),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ));
                          } else {
                            return Container();
                          }
                        });
                  })
            ],
          ),
        ),
      ),
    );
  }
}
