import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/events/manager_events.dart';
import 'package:event_handler/screens/events/my_events.dart';
import 'package:event_handler/screens/add_local.dart';
import 'package:event_handler/screens/my_locals.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Profile extends StatelessWidget {
  Profile({Key? key, required this.databaseService, required this.authService})
      : super(key: key);
  final DatabaseService databaseService;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF121B22),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
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
                          backgroundColor: Colors.black54,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade400,
                            child: FutureBuilder(
                              future: databaseService.getCurrentUser(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<AppUser> myLocals) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (myLocals.data != null)
                                      Text(
                                        myLocals.data != null
                                            ? (myLocals.data!.name[0]
                                                    .toUpperCase() +
                                                "" +
                                                myLocals.data!.surname[0]
                                                    .toUpperCase())
                                            : 'No Name',
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w400,
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
                        future: databaseService.getCurrentUser(),
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
                                            myLocals.data!.name.substring(1))
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
                        future: databaseService.getCurrentUser(),
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
                                            myLocals.data!.surname.substring(1))
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
                    future: databaseService.getCurrentUser(),
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
                                    fontSize: 18,
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
                          primary: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          shadowColor: Colors.grey.shade400),
                      child: Text(
                        'My events',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyEvents(
                                  databaseService: DatabaseService(
                                      AuthService(FirebaseAuth.instance)
                                          .getCurrentUser()!
                                          .uid,
                                      FirebaseFirestore.instance),
                                  authService:
                                      AuthService(FirebaseAuth.instance))),
                        );
                      }),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 18,
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          onSurface: Colors.green,
                          primary: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          shadowColor: Colors.grey.shade400),
                      child: Text(
                        'Organized Events',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManagerEvents(
                                  databaseService: DatabaseService(
                                      AuthService(FirebaseAuth.instance)
                                          .getCurrentUser()!
                                          .uid,
                                      FirebaseFirestore.instance),
                                  authService:
                                      AuthService(FirebaseAuth.instance))),
                        );
                      }),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 18,
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          onSurface: Colors.green,
                          primary: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          shadowColor: Colors.grey.shade400),
                      child: Text(
                        'My Locals',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyLocals(
                                    databaseService: DatabaseService(
                                        AuthService(FirebaseAuth.instance)
                                            .getCurrentUser()!
                                            .uid,
                                        FirebaseFirestore.instance),
                                  )),
                        );
                      }),
                ),
                SizedBox(height: 70),

                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: 3, bottom: 3),
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
                      child: Text(
                        'Log Out',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () async {
                        await authService.signOut();
                      }),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "OR",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      buildDivider(),
                    ],
                  ),
                ),

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
                  height: MediaQuery.of(context).size.height / 24,
                  padding: EdgeInsets.symmetric(vertical: 0),
                  margin: EdgeInsets.symmetric(vertical: 0),
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
                    onPressed: () => {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
