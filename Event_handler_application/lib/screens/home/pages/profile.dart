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
  Profile({Key? key, required this.databaseService, required this.authService})
      : super(key: key);
  final DatabaseService databaseService;
  final AuthService authService;

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
                  await authService.signOut();
                }),
            SizedBox(height: 20),
            FutureBuilder<AppUser>(
                future: databaseService.getCurrentAppUser(),
                builder:
                    (BuildContext context, AsyncSnapshot<AppUser> appUser) {
                  if (appUser.connectionState == ConnectionState.done) {
                    if (appUser.data!.isOwner) {
                      return ElevatedButton(
                          child: Text('Organized events'),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagerEvents(
                                      databaseService: databaseService,
                                      authService: authService)),
                            );
                          });
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
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
            FutureBuilder<AppUser>(
                future: databaseService.getCurrentAppUser(),
                builder:
                    (BuildContext context, AsyncSnapshot<AppUser> appUser) {
                  if (appUser.connectionState == ConnectionState.done) {
                    if (appUser.data!.isOwner) {
                      return ElevatedButton(
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
                          });
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                }),
          ])),
    );
  }
}
