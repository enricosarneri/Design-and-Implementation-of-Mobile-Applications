import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/screens/events/transformers.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/services/database%20services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transformer_page_view/transformer_page_view.dart';

class MyEvents extends StatefulWidget {
  MyEvents({Key? key, required this.databaseService, required this.authService})
      : super(key: key);
  final DatabaseService databaseService;
  final AuthService authService;
  _MyEventsState createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return WideLayout(
                authService: widget.authService,
                databaseService: widget.databaseService);
          } else {
            return NarrowLayout(
                authService: widget.authService,
                databaseService: widget.databaseService);
          }
        },
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  final authService;
  final databaseService;
  @override
  NarrowLayout({Key? key, this.authService, this.databaseService})
      : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = widget.databaseService.getEvents();
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
                    child: TransformerPageView(
                        pageController: TransformerPageController(
                            initialPage: 0,
                            viewportFraction: 0.5,
                            itemCount: data.size),
                        curve: Curves.easeInBack,
                        transformer: transformers[3],
                        scrollDirection: Axis.vertical,
                        // shrinkWrap: true,
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          for (var i = 0;
                              i < data.docs[index]['partecipants'].length;
                              i++) {
                            if (data.docs[index]['partecipants'][i] ==
                                widget.authService.getCurrentUser()!.uid) {
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
                                            top: 30,
                                            left: 15,
                                            right: 15,
                                            bottom: 30,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${data.docs[index]['name']}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                                              SizedBox(height: 10),
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
                                                  RichText(
                                                      text: TextSpan(children: [
                                                    TextSpan(
                                                      text: "From: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${data.docs[index]['dateBegin']}'
                                                              .substring(0, 10),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text: " at: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${data.docs[index]['dateBegin']}'
                                                              .substring(
                                                                  11, 16),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  ])),
                                                ],
                                              ),
                                              SizedBox(height: 5),
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
                                                  RichText(
                                                      text: TextSpan(children: [
                                                    TextSpan(
                                                      text: "To: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${data.docs[index]['dateEnd']}'
                                                              .substring(0, 10),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text: " at: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${data.docs[index]['dateEnd']}'
                                                              .substring(
                                                                  11, 16),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  ])),
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
                                                          fontSize: 14,
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
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Event Privacy: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                '${data.docs[index]['eventType']}',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
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
                                                                fontSize: 14),
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

class WideLayout extends StatefulWidget {
  final authService;
  final databaseService;
  @override
  WideLayout({Key? key, this.authService, this.databaseService})
      : super(key: key);
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = widget.databaseService.getEvents();
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
        color: Color(0xFF121B22),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10.0),
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
                  margin: EdgeInsets.symmetric(vertical: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    child: TransformerPageView(
                        scrollDirection: Axis.horizontal,
                        pageController: TransformerPageController(
                            initialPage: 0,
                            viewportFraction: 0.5,
                            itemCount: data.size),
                        curve: Curves.easeInBack,
                        transformer: transformers[5],
                        // shrinkWrap: true,
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          for (var i = 0;
                              i < data.docs[index]['partecipants'].length;
                              i++) {
                            if (data.docs[index]['partecipants'][i] ==
                                widget.authService.getCurrentUser()!.uid) {
                              return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: Colors.transparent),
                                    shape: BoxShape.rectangle,
                                    color: Colors.black12.withOpacity(0.4),
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 30),
                                  width: MediaQuery.of(context).size.width / 3,
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
                                            top: 50,
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
                                              SizedBox(
                                                height: 10,
                                              ),
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
                                              SizedBox(
                                                height: 10,
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
                                                    '${data.docs[index]['dateBegin']}'
                                                        .substring(0, 16),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
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
                                                    'Ending: ' +
                                                        '${data.docs[index]['dateEnd']}'
                                                            .substring(0, 16),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 50),
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
                                              SizedBox(height: 10),
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
                                              SizedBox(height: 2),
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
