import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/add_local.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyLocals extends StatefulWidget {
  const MyLocals({Key? key}) : super(key: key);

  @override
  _MyLocalsState createState() => _MyLocalsState();
}

class _MyLocalsState extends State<MyLocals> {
  final AuthService _authService = AuthService(FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Locals')),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                  child: Text('Add Local'),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddLocal(
                                authService: _authService,
                              )),
                    );
                  }),
              FutureBuilder(
                  future: DatabaseService(_authService.getCurrentUser()!.uid,
                          FirebaseFirestore.instance)
                      .getMyLocals(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Local>> myLocals) {
                    return Container(
                        child: Column(
                      children: [
                        if (myLocals.data != null)
                          for (int i = 0; i < myLocals.data!.length; i++)
                            Text(myLocals.data != null
                                ? myLocals.data![i].localAddress
                                : 'You own no local'),
                        SizedBox(height: 20),
                      ],
                    ));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
