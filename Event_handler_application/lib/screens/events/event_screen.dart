import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/qr_scan_page.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key, required this.event}) : super(key: key);
  final Event event;

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final String userId= _authService.getCurrentUser()!.uid;
    Stream<QuerySnapshot> users =
        DatabaseService(userId).getUsers();
    bool isManager= userId== widget.event.getManagerId;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.event.name,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 24),
              Text(
                widget.event.description,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 24),
              Text(
                'max partecipants: ' + widget.event.maxPartecipants.toString(),
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 24),
              Text(
                'Place : ' + widget.event.placeName,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
              ),
              if(isManager) SizedBox(height: 24),
                Text(
                'People asking to join: ' +
                    widget.event.applicants.length.toString(),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              if(isManager) StreamBuilder(
                  stream: users,
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
                              i < widget.event.applicants.length;
                              i++) {
                            if (widget.event.applicants.isNotEmpty &&
                                widget.event.applicants[i] ==
                                    data.docs[index].id) {
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
                                          Column(
                                            children: [
                                              Text(
                                                  '${data.docs[index]['name']} ${data.docs[index]['surname']} '),
                                              SizedBox(height: 10),
                                              Text(
                                                  '${data.docs[index]['email']}'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.check_outlined),
                                                onPressed: () {
                                                  setState(() {
                                                    DatabaseService(_authService
                                                            .getCurrentUser()!
                                                            .uid)
                                                        .acceptApplicance(
                                                            widget.event,
                                                            data.docs[index]
                                                                .id);
                                                  });
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.close_outlined),
                                                onPressed: () {
                                                  setState(() {
                                                    DatabaseService(_authService
                                                            .getCurrentUser()!
                                                            .uid)
                                                        .refuseApplicance(
                                                            widget.event,
                                                            data.docs[index]
                                                                .id);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ));
                            }
                          }
                          {
                            return Container();
                          }
                        });
                  }),
              if(isManager)Text(
                'Partecipants ' + widget.event.partecipants.length.toString(),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              if(isManager) StreamBuilder(
                  stream: users,
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
                              i < widget.event.partecipants.length;
                              i++) {
                            if (widget.event.partecipants.isNotEmpty &&
                                widget.event.partecipants[i] ==
                                    data.docs[index].id) {
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
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${data.docs[index]['name']} ${data.docs[index]['surname']} '),
                                          SizedBox(height: 10),
                                          Text('${data.docs[index]['email']}'),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ));
                            }
                          }
                          {
                            return Container();
                          }
                        });
                  }),
              if(isManager) ElevatedButton(
                  child: const Text('Scan Qr'),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QrScanPage(event: widget.event,)),
                    );
                  }),
              if(!isManager)FutureBuilder(
                future: DatabaseService(_authService.getCurrentUser()!.uid).getQrCodeByUserEvent(widget.event, userId),
                initialData: "Loading text..",
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                return QrImage(
                  data: text.data!,
                  size: 200,
                  backgroundColor: Colors.white,
                  );
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}
