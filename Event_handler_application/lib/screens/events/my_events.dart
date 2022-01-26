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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'My Events',
        ),
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        color: Color(0xFF121B22),
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          child: StreamBuilder(
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
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    child: ListView.builder(
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
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: Colors.transparent),
                                    shape: BoxShape.rectangle,
                                    color: Colors.black12.withOpacity(0.4),
                                  ),
                                  margin: EdgeInsets.all(10),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: Stack(
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (rect) {
                                            return LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black54,
                                                Colors.transparent
                                              ],
                                            ).createShader(Rect.fromLTRB(
                                                0, 0, rect.width, rect.height));
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: new DecorationImage(
                                                  image: new NetworkImage(
                                                    data.docs[index]
                                                        ['urlImage'],
                                                  ),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            left: 10,
                                            right: 10,
                                            bottom: 10,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${data.docs[index]['name']}',
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.date_range_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    '${data.docs[index]['date']}'
                                                        .substring(0, 10),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  width: 30,
                                                  height: 3,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.place,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                      '${data.docs[index]['placeName']}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white)),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.privacy_tip_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      'Event Privacy: ${data.docs[index]['eventType']}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 16,
                                                          color: Colors.white)),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        primary: Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'More Info',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF121B22),
                                                                fontSize: 16),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            Icons.info,
                                                            color: Color(
                                                                0xFF121B22),
                                                          ),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        Event event = Event(
                                                            data.docs[index]
                                                                ['manager'],
                                                            data.docs[index]
                                                                ['name'],
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
                                                                ['typeOfPlace'],
                                                            data.docs[index]
                                                                ['eventType'],
                                                            data.docs[index]
                                                                ['dateBegin'],
                                                            data.docs[index]
                                                                ['dateEnd'],
                                                            data.docs[index][
                                                                'maxPartecipants'],
                                                            data.docs[index]
                                                                ['price'],
                                                            data.docs[index]
                                                                ['eventId'],
                                                            List<String>.from(data
                                                                    .docs[index]
                                                                [
                                                                'partecipants']),
                                                            List<String>.from(data.docs[index]['applicants']),
                                                            List<String>.from(data.docs[index]['qrCodeList']),
                                                            data.docs[index]['firstFreeQrCode']);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => EventScreen(
                                                                  event: event,
                                                                  authService:
                                                                      AuthService(
                                                                          FirebaseAuth
                                                                              .instance),
                                                                  databaseService: DatabaseService(
                                                                      AuthService(FirebaseAuth
                                                                              .instance)
                                                                          .getCurrentUser()!
                                                                          .uid,
                                                                      FirebaseFirestore
                                                                          .instance))),
                                                          //  Event(this.managerId, this.name, this.description, this.latitude, this.longitude, this.placeName,this.eventType,this.date, this.maxPartecipants, this.eventId, this.partecipants, this.applicants, this.qrCodes);
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }
                          }
                          return Container();
                        }),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
