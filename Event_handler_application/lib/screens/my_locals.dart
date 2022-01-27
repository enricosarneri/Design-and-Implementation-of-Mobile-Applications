import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/add_local.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyLocals extends StatefulWidget {
  const MyLocals({Key? key, required this.databaseService}) : super(key: key);
  final DatabaseService databaseService;

  @override
  _MyLocalsState createState() => _MyLocalsState();
}

class _MyLocalsState extends State<MyLocals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return WideLayout(databaseService: widget.databaseService);
          } else {
            return NarrowLayout(databaseService: widget.databaseService);
          }
        },
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  final DatabaseService? databaseService;
  @override
  NarrowLayout({Key? key, this.databaseService}) : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'My Locals',
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
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
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
                          Text(
                            'Add Local',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          )
                        ]),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddLocal(
                                  authService:
                                      AuthService(FirebaseAuth.instance),
                                )),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
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
                FutureBuilder(
                  future: widget.databaseService!.getMyLocals(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Local>> myLocals) {
                    return Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(vertical: 40, horizontal: 2),
                      child: Column(
                        children: [
                          if (myLocals.data != null)
                            for (int i = 0; i < myLocals.data!.length; i++)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.place,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        myLocals.data != null
                                            ? myLocals.data![i].localName
                                            : 'You own no local',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    myLocals.data != null
                                        ? myLocals.data![i].localAddress
                                        : 'You own no local',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 80),
                                    child: Divider(
                                      thickness: 1.5,
                                      color: Colors.white,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WideLayout extends StatefulWidget {
  final DatabaseService? databaseService;
  @override
  WideLayout({Key? key, this.databaseService}) : super(key: key);
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'My Locals',
        ),
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 150),
        color: Color(0xFF121B22),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 300),
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
                          Text(
                            'Add Local',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          )
                        ]),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddLocal(
                                  authService:
                                      AuthService(FirebaseAuth.instance),
                                )),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
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
                FutureBuilder(
                  future: widget.databaseService!.getMyLocals(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Local>> myLocals) {
                    return Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(vertical: 40, horizontal: 2),
                      child: Column(
                        children: [
                          if (myLocals.data != null)
                            for (int i = 0; i < myLocals.data!.length; i++)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.place,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        myLocals.data != null
                                            ? myLocals.data![i].localName
                                            : 'You own no local',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    myLocals.data != null
                                        ? myLocals.data![i].localAddress
                                        : 'You own no local',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 80),
                                    child: Divider(
                                      thickness: 1.5,
                                      color: Colors.white,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
