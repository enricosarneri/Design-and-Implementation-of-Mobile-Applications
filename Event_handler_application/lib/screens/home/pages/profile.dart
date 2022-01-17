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

class Profile extends StatelessWidget {
  final AuthService auth = AuthService(FirebaseAuth.instance);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My profile')),
      body: Container(
          margin: EdgeInsets.all(24),
          child: ListView(children: <Widget>[
            ElevatedButton(
                child: Text('log out'),
                onPressed: () async {
                  await auth.signOut();
                }),
            SizedBox(height: 20),
            ElevatedButton(
                child: Text('Organized events'),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManagerEvents()),
                  );
                }),
            SizedBox(height: 20),
            ElevatedButton(
                child: Text('My events'),
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
                              authService: AuthService(FirebaseAuth.instance),
                            )),
                  );
                }),
            SizedBox(height: 20),
            ElevatedButton(
                child: Text('My Locals'),
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
          ])),
    );
  }
}
