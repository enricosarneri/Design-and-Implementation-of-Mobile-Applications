import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/events/manager_events.dart';
import 'package:event_handler/screens/events/my_events.dart';
import 'package:event_handler/screens/locals/add_local.dart';
import 'package:event_handler/screens/home/utilities/custom_rect_tween.dart';
import 'package:event_handler/screens/home/utilities/hero_dialogue_route.dart';
import 'package:event_handler/screens/locals/my_locals.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/services/database%20services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, required this.databaseService, required this.authService})
      : super(key: key);
  final DatabaseService databaseService;
  final AuthService authService;

  //bool isManger = true;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
  final DatabaseService? databaseService;
  final AuthService? authService;
  @override
  NarrowLayout({Key? key, this.databaseService, this.authService})
      : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  String _contactUs = "";
  late Timer _timer;
  @override
  Widget build(BuildContext context) {
    //setIsManger();
    return Scaffold(
      body: FutureBuilder<AppUser>(
          future: widget.databaseService!.getCurrentAppUser(),
          builder: (BuildContext context, AsyncSnapshot<AppUser> appUser) {
            if (appUser.connectionState == ConnectionState.done) {
              return Container(
                color: Color(0xFF121B22),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 13,
                  ),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 115,
                            width: 115,
                            child: Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.expand,
                              children: [
                                Material(
                                  borderRadius: BorderRadius.circular(90),
                                  shadowColor: Colors.black87,
                                  elevation: 8,
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.black45,
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Color(0xFF8596a0),
                                      child: FutureBuilder(
                                        future: widget.databaseService!
                                            .getCurrentUser(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<AppUser> myLocals) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              if (myLocals.data != null)
                                                Text(
                                                  myLocals.data != null
                                                      ? (myLocals.data!.name[0]
                                                              .toUpperCase() +
                                                          "" +
                                                          myLocals
                                                              .data!.surname[0]
                                                              .toUpperCase())
                                                      : 'No Name',
                                                  style: TextStyle(
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10, bottom: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder(
                                  future:
                                      widget.databaseService!.getCurrentUser(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<AppUser> myLocals) {
                                    return Container(
                                      child: Column(
                                        children: [
                                          if (myLocals.data != null)
                                            Text(
                                              myLocals.data != null
                                                  ? (myLocals.data!.name[0]
                                                          .toUpperCase() +
                                                      myLocals.data!.name
                                                          .substring(1))
                                                  : 'No Name',
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 5),
                                FutureBuilder(
                                  future:
                                      widget.databaseService!.getCurrentUser(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<AppUser> myLocals) {
                                    return Container(
                                      child: Column(
                                        children: [
                                          if (myLocals.data != null)
                                            Text(
                                              myLocals.data != null
                                                  ? (myLocals.data!.surname[0]
                                                          .toUpperCase() +
                                                      myLocals.data!.surname
                                                          .substring(1))
                                                  : 'No Surname',
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FutureBuilder(
                              future: widget.databaseService!.getCurrentUser(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<AppUser> myLocals) {
                                return Container(
                                  child: Column(
                                    children: [
                                      if (myLocals.data != null)
                                        Text(
                                          myLocals.data != null
                                              ? (myLocals.data!.email)
                                              : 'No Email',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 18,
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  onSurface: Colors.green,
                                  primary: Color(0xFF8596a0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  'My events',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyEvents(
                                            databaseService: DatabaseService(
                                                AuthService(
                                                        FirebaseAuth.instance)
                                                    .getCurrentUser()!
                                                    .uid,
                                                FirebaseFirestore.instance),
                                            authService: AuthService(
                                                FirebaseAuth.instance))),
                                  );
                                }),
                          ),
                          if (appUser.data!.isOwner) SizedBox(height: 20),
                          if (appUser.data!.isOwner)
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 18,
                              padding: EdgeInsets.symmetric(horizontal: 60),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onSurface: Colors.green,
                                    primary: Color(0xFF8596a0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Organized Events',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ManagerEvents(
                                              databaseService: DatabaseService(
                                                  AuthService(
                                                          FirebaseAuth.instance)
                                                      .getCurrentUser()!
                                                      .uid,
                                                  FirebaseFirestore.instance),
                                              authService: AuthService(
                                                  FirebaseAuth.instance))),
                                    );
                                  }),
                            ),
                          if (appUser.data!.isOwner) SizedBox(height: 20),
                          if (appUser.data!.isOwner)
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 18,
                              padding: EdgeInsets.symmetric(horizontal: 60),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onSurface: Colors.green,
                                    primary: Color(0xFF8596a0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text(
                                    'My Locals',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyLocals(
                                                databaseService:
                                                    DatabaseService(
                                                        AuthService(FirebaseAuth
                                                                .instance)
                                                            .getCurrentUser()!
                                                            .uid,
                                                        FirebaseFirestore
                                                            .instance),
                                              )),
                                    );
                                  }),
                            ),
                          SizedBox(height: 60),

                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 30,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // TextSpan(
                          //                   text: '  Sign Up',
                          //                   style: TextStyle(
                          //                       color: Colors.black,
                          //                       fontWeight: FontWeight.bold),
                          //                   recognizer: TapGestureRecognizer()
                          //                     ..onTap = () {
                          //                       Navigator.push(
                          //                           context,
                          //                           MaterialPageRoute(
                          //                               builder: (context) =>
                          //                                   Registration()));
                          //                     },
                          //                 ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 18,
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: Colors.transparent,
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
                                  Icon(Icons.logout),
                                  SizedBox(width: 5),
                                  Text(
                                    'Log Out',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                await widget.authService!.signOut();
                              },
                            ),
                          ),

                          SizedBox(height: 40),
                          // Align(
                          //   alignment: Alignment.topCenter,
                          //   child: Container(
                          //     margin:
                          //         EdgeInsets.only(top: 3, bottom: 3, right: 10, left: 10),
                          //     height: 1,
                          //     decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //   ),
                          // ),
                          Container(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width / 3,
                                right: MediaQuery.of(context).size.width / 3),
                            alignment: Alignment.center,
                            child: Row(
                              children: <Widget>[
                                buildDivider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                                buildDivider(),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: MediaQuery.of(context).size.height / 24,
                            padding: EdgeInsets.symmetric(vertical: 0),
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: TextButton(
                              child: Text(
                                'Go back to the Tutorial',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () => {},
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: MediaQuery.of(context).size.height / 24,
                            padding: EdgeInsets.symmetric(vertical: 0),
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: "20",
                                  child: TextButton(
                                    child: Text(
                                      'Contact us',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () => {
                                      Navigator.of(context).push(
                                        HeroDialogRoute(
                                          builder: (context) => Center(
                                            child: Hero(
                                              tag: "20",
                                              createRectTween: (begin, end) {
                                                return CustomRectTween(
                                                    begin: begin, end: end);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Material(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: Color(0xFF8596a0),
                                                  child: SizedBox(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons.help,
                                                                    color: Colors
                                                                        .black54,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    "Contact Us",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black54,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black12,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                initialValue:
                                                                    _contactUs,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .multiline,
                                                                maxLines: null,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration: InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .all(
                                                                                8),
                                                                    hintText:
                                                                        'Write the message...',
                                                                    border:
                                                                        InputBorder
                                                                            .none),
                                                                onChanged:
                                                                    (value) {
                                                                  _contactUs =
                                                                      value
                                                                          .trim();
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          30),
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  elevation: 0,
                                                                  primary: Colors
                                                                      .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                  ),
                                                                  //  shadowColor: Colors.grey.shade400),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              20),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          'Send',
                                                                          style: TextStyle(
                                                                              color: Color(0xFF121B22),
                                                                              fontSize: 16),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                5),
                                                                        Icon(
                                                                          Icons
                                                                              .send,
                                                                          color:
                                                                              Color(0xFF121B22),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  if (_contactUs !=
                                                                      "")
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                builderContext) {
                                                                          _timer = Timer(
                                                                              Duration(milliseconds: 1200),
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          });

                                                                          return Container(
                                                                            margin: EdgeInsets.only(
                                                                                bottom: 50,
                                                                                left: 12,
                                                                                right: 12),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.transparent,
                                                                              borderRadius: BorderRadius.circular(40),
                                                                            ),
                                                                            child:
                                                                                AlertDialog(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                                              elevation: 20,
                                                                              backgroundColor: Colors.white.withOpacity(0.8),
                                                                              content: SingleChildScrollView(
                                                                                child: Text(
                                                                                  'Your message has been sent successfully!',
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }).then((val) {
                                                                      if (_timer
                                                                          .isActive) {
                                                                        _timer
                                                                            .cancel();
                                                                      }
                                                                    });
                                                                  _contactUs =
                                                                      "";
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.help,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              ));
          }),
    );
  }
}

class WideLayout extends StatefulWidget {
  final DatabaseService? databaseService;
  final AuthService? authService;
  @override
  WideLayout({Key? key, this.databaseService, this.authService})
      : super(key: key);
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  String _contactUs = "";
  late Timer _timer;
  @override
  Widget build(BuildContext context) {
    //setIsManger();
    return Scaffold(
      body: FutureBuilder<AppUser>(
          future: widget.databaseService!.getCurrentAppUser(),
          builder: (BuildContext context, AsyncSnapshot<AppUser> appUser) {
            if (appUser.connectionState == ConnectionState.done) {
              return Container(
                color: Color(0xFF121B22),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Center(
                  child: Container(
                    // margin: EdgeInsets.only(
                    //   bottom: MediaQuery.of(context).size.height / 13,
                    // ),
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 115,
                              width: 115,
                              child: Stack(
                                clipBehavior: Clip.none,
                                fit: StackFit.expand,
                                children: [
                                  Material(
                                    borderRadius: BorderRadius.circular(90),
                                    shadowColor: Colors.black87,
                                    elevation: 8,
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundColor: Colors.black45,
                                      child: CircleAvatar(
                                        radius: 55,
                                        backgroundColor: Color(0xFF8596a0),
                                        child: FutureBuilder(
                                          future: widget.databaseService!
                                              .getCurrentUser(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<AppUser> myLocals) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (myLocals.data != null)
                                                  Text(
                                                    myLocals.data != null
                                                        ? (myLocals
                                                                .data!.name[0]
                                                                .toUpperCase() +
                                                            "" +
                                                            myLocals.data!
                                                                .surname[0]
                                                                .toUpperCase())
                                                        : 'No Name',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder(
                                    future: widget.databaseService!
                                        .getCurrentUser(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<AppUser> myLocals) {
                                      return Container(
                                        child: Column(
                                          children: [
                                            if (myLocals.data != null)
                                              Text(
                                                myLocals.data != null
                                                    ? (myLocals.data!.name[0]
                                                            .toUpperCase() +
                                                        myLocals.data!.name
                                                            .substring(1))
                                                    : 'No Name',
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 5),
                                  FutureBuilder(
                                    future: widget.databaseService!
                                        .getCurrentUser(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<AppUser> myLocals) {
                                      return Container(
                                        child: Column(
                                          children: [
                                            if (myLocals.data != null)
                                              Text(
                                                myLocals.data != null
                                                    ? (myLocals.data!.surname[0]
                                                            .toUpperCase() +
                                                        myLocals.data!.surname
                                                            .substring(1))
                                                    : 'No Surname',
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: FutureBuilder(
                                future:
                                    widget.databaseService!.getCurrentUser(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<AppUser> myLocals) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        if (myLocals.data != null)
                                          Text(
                                            myLocals.data != null
                                                ? (myLocals.data!.email)
                                                : 'No Email',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white),
                                          ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 40),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 18,
                              padding: EdgeInsets.symmetric(horizontal: 350),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onSurface: Colors.green,
                                    primary: Color(0xFF8596a0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text(
                                    'My events',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyEvents(
                                              databaseService: DatabaseService(
                                                  AuthService(
                                                          FirebaseAuth.instance)
                                                      .getCurrentUser()!
                                                      .uid,
                                                  FirebaseFirestore.instance),
                                              authService: AuthService(
                                                  FirebaseAuth.instance))),
                                    );
                                  }),
                            ),
                            if (appUser.data!.isOwner) SizedBox(height: 20),
                            if (appUser.data!.isOwner)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 18,
                                padding: EdgeInsets.symmetric(horizontal: 350),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      onSurface: Colors.green,
                                      primary: Color(0xFF8596a0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    child: Text(
                                      'Organized Events',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ManagerEvents(
                                                databaseService:
                                                    DatabaseService(
                                                        AuthService(FirebaseAuth
                                                                .instance)
                                                            .getCurrentUser()!
                                                            .uid,
                                                        FirebaseFirestore
                                                            .instance),
                                                authService: AuthService(
                                                    FirebaseAuth.instance))),
                                      );
                                    }),
                              ),
                            if (appUser.data!.isOwner) SizedBox(height: 20),
                            if (appUser.data!.isOwner)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 18,
                                padding: EdgeInsets.symmetric(horizontal: 350),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      onSurface: Colors.green,
                                      primary: Color(0xFF8596a0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    child: Text(
                                      'My Locals',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyLocals(
                                                  databaseService:
                                                      DatabaseService(
                                                          AuthService(
                                                                  FirebaseAuth
                                                                      .instance)
                                                              .getCurrentUser()!
                                                              .uid,
                                                          FirebaseFirestore
                                                              .instance),
                                                )),
                                      );
                                    }),
                              ),
                            SizedBox(height: 60),

                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 30,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            // TextSpan(
                            //                   text: '  Sign Up',
                            //                   style: TextStyle(
                            //                       color: Colors.black,
                            //                       fontWeight: FontWeight.bold),
                            //                   recognizer: TapGestureRecognizer()
                            //                     ..onTap = () {
                            //                       Navigator.push(
                            //                           context,
                            //                           MaterialPageRoute(
                            //                               builder: (context) =>
                            //                                   Registration()));
                            //                     },
                            //                 ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 18,
                              padding: EdgeInsets.symmetric(horizontal: 350),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: Colors.transparent,
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
                                    Icon(Icons.logout),
                                    SizedBox(width: 5),
                                    Text(
                                      'Log Out',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  await widget.authService!.signOut();
                                },
                              ),
                            ),

                            SizedBox(height: 70),
                            // Align(
                            //   alignment: Alignment.topCenter,
                            //   child: Container(
                            //     margin:
                            //         EdgeInsets.only(top: 3, bottom: 3, right: 10, left: 10),
                            //     height: 1,
                            //     decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //   ),
                            // ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 3,
                                  right: MediaQuery.of(context).size.width / 3),
                              alignment: Alignment.center,
                              child: Row(
                                children: <Widget>[
                                  buildDivider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                                  buildDivider(),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: MediaQuery.of(context).size.height / 24,
                              padding: EdgeInsets.symmetric(vertical: 0),
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: TextButton(
                                child: Text(
                                  'Go back to the Tutorial',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () => {},
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              height: MediaQuery.of(context).size.height / 24,
                              padding: EdgeInsets.symmetric(vertical: 0),
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Hero(
                                    tag: "20",
                                    child: TextButton(
                                      child: Text(
                                        'Contact us',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      onPressed: () => {
                                        Navigator.of(context).push(
                                          HeroDialogRoute(
                                            builder: (context) => Center(
                                              child: Hero(
                                                tag: "20",
                                                createRectTween: (begin, end) {
                                                  return CustomRectTween(
                                                      begin: begin, end: end);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 16,
                                                    horizontal: 350,
                                                  ),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .help,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      "Contact Us",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .black12,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                child:
                                                                    TextFormField(
                                                                  initialValue:
                                                                      _contactUs,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .multiline,
                                                                  maxLines:
                                                                      null,
                                                                  cursorColor:
                                                                      Colors
                                                                          .black,
                                                                  decoration: InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      hintText:
                                                                          'Write the message...',
                                                                      border: InputBorder
                                                                          .none),
                                                                  onChanged:
                                                                      (value) {
                                                                    _contactUs =
                                                                        value
                                                                            .trim();
                                                                  },
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            30),
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    elevation:
                                                                        0,
                                                                    primary: Colors
                                                                        .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    //  shadowColor: Colors.grey.shade400),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            'Send',
                                                                            style:
                                                                                TextStyle(color: Color(0xFF121B22), fontSize: 16),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 5),
                                                                          Icon(
                                                                            Icons.send,
                                                                            color:
                                                                                Color(0xFF121B22),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    if (_contactUs !=
                                                                        "")
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (BuildContext builderContext) {
                                                                            _timer =
                                                                                Timer(Duration(milliseconds: 1200), () {
                                                                              Navigator.of(context).pop();
                                                                            });

                                                                            return Container(
                                                                              margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.transparent,
                                                                                borderRadius: BorderRadius.circular(40),
                                                                              ),
                                                                              child: AlertDialog(
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                                                elevation: 20,
                                                                                backgroundColor: Colors.white.withOpacity(0.8),
                                                                                content: SingleChildScrollView(
                                                                                  child: Text(
                                                                                    'Your message has been sent successfully!',
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).then((val) {
                                                                        if (_timer
                                                                            .isActive) {
                                                                          _timer
                                                                              .cancel();
                                                                        }
                                                                      });
                                                                    _contactUs =
                                                                        "";
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      },
                                    ),
                                  ),
                                  Icon(
                                    Icons.help,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              ));
          }),
    );
  }
}

Expanded buildDivider() {
  return Expanded(
    child: Divider(
      thickness: 1.5,
      color: Colors.white,
      height: 15,
    ),
  );
}
