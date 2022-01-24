import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/events/show_qr.dart';
import 'package:event_handler/screens/qr_scan_page.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({
    Key? key,
    required this.event,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);
  final Event event;
  final AuthService authService;
  final DatabaseService databaseService;

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    Stream<QuerySnapshot> events = DatabaseService(
            widget.authService.getCurrentUser()!.uid,
            FirebaseFirestore.instance)
        .getEvents();
    final String userId = widget.authService.getCurrentUser()!.uid;

    Stream<QuerySnapshot> users = widget.databaseService.getUsers();
    bool isManager = userId == widget.event.getManagerId;

    int isPartecipantInTheEvent = 0;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          '',
        ),
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        color: Color(0xFF121B22),
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
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
                        primary: false,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: data.size,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (data.docs[index]['urlImage'] ==
                              widget.event.getUrlImage) {
                            return Container(
                              padding: EdgeInsets.only(top: 0),
                              margin: EdgeInsets.only(top: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                // boxShadow: [
                                //   BoxShadow(
                                //       color: Colors.grey.withOpacity(0.6),
                                //       offset: const Offset(0, 8),
                                //       blurRadius: 6.0,
                                //       spreadRadius: 0)
                                // ],
                              ),
                              height: MediaQuery.of(context).size.height / 5.5,
                              //   margin: EdgeInsets.only(top: 7, right: 5, left: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(top: 0),
                                  margin: EdgeInsets.only(top: 0),
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black38,
                                          Colors.transparent
                                        ],
                                      ).createShader(Rect.fromLTRB(
                                          0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: Image.network(
                                      data.docs[index]['urlImage'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Center();
                        },
                      );
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 5,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(bottom: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.event.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 32),
                        ),
                        Container(
                          child: FutureBuilder(
                            future: DatabaseService(
                                    widget.authService.getCurrentUser()!.uid,
                                    FirebaseFirestore.instance)
                                .getMyLocals(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Local>> myLocals) {
                              return Container(
                                  margin: EdgeInsets.only(
                                      top: 5, right: 5, left: 5),
                                  child: Column(
                                    children: [
                                      if (myLocals.data != null)
                                        for (int i = 0;
                                            i < myLocals.data!.length;
                                            i++)
                                          if (myLocals.data![i].localName ==
                                              widget.event.placeName)
                                            Text(
                                              myLocals.data![i].localAddress,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                    ],
                                  ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              SizedBox(height: 5),
              Align(
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.black12.withOpacity(0.4),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: MediaQuery.of(context).size.height / 10,
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      thickness: 10,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        //   controller: controller,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        children: [
                          Text(
                            widget.event.description,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (!isManager)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Partecipants: ' +
                          widget.event.partecipants.length.toString() +
                          '/' +
                          widget.event.maxPartecipants.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ],
                ),
              if (!isManager) SizedBox(height: 10),
              if (!isManager)
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
              if (!isManager)
                SizedBox(
                  height: 15,
                ),
              if (!isManager)
                if (!widget.event.partecipants
                    .contains(widget.authService.getCurrentUser()!.uid))
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 90),
                      height: MediaQuery.of(context).size.height / 18,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          // side: BorderSide(color: Colors.black)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ask to Partecipate',
                              style: TextStyle(
                                  color: Color(0xFF121B22), fontSize: 16),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.notifications, color: Color(0xFF121B22)),
                          ],
                        ),
                        onPressed: () async {
                          final AuthService _authService =
                              AuthService(FirebaseAuth.instance);
                          DatabaseService(_authService.getCurrentUser()!.uid,
                                  FirebaseFirestore.instance)
                              .addEventApplicant(widget.event);
                          //oppure mostrare un messagio con scritto Richiesta inviata con successo
                        },
                      ),
                    ),
                  ),
              if (!isManager)
                if (widget.event.partecipants
                    .contains(widget.authService.getCurrentUser()!.uid))
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 90),
                      height: MediaQuery.of(context).size.height / 18,
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
                              'Ask to Partecipate',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.notifications),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
              if (!isManager)
                SizedBox(
                  height: 10,
                ),
              if (isManager)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'People asking to join: ' +
                          widget.event.applicants.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ],
                ),
              if (isManager)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.rectangle,
                    color: Colors.black12.withOpacity(0.4),
                  ),
                  width: MediaQuery.of(context).size.width / 1.2,
                  margin: EdgeInsets.all(10),
                  child: StreamBuilder(
                      stream: users,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('loading');
                        }
                        final data = snapshot.requireData;

                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 10,
                          child: ListView.builder(
                              primary: false,
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
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 10,
                                          top: 5,
                                          bottom: 10),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                '${data.docs[index]['name']} ${data.docs[index]['surname']} ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                  '${data.docs[index]['email']}',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.check_outlined,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    widget.databaseService
                                                        .acceptApplicance(
                                                            widget.event,
                                                            data.docs[index]
                                                                .id);
                                                  });
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close_outlined,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    widget.databaseService
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
                                    );
                                  }
                                }
                                {
                                  return Container();
                                }
                              }),
                        );
                      }),
                ),
              if (isManager)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Partecipants: ' +
                          widget.event.partecipants.length.toString() +
                          '/' +
                          widget.event.maxPartecipants.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ],
                ),
              if (isManager)
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.rectangle,
                    color: Colors.black12.withOpacity(0.4),
                  ),
                  margin: EdgeInsets.all(10),
                  child: StreamBuilder(
                      stream: users,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('loading');
                        }
                        final data = snapshot.requireData;

                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 10,
                          child: ListView.builder(
                              primary: false,
                              key: Key("list view"),
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
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              left: 10,
                                              right: 10,
                                              bottom: 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${data.docs[index]['name']} ${data.docs[index]['surname']} ',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              SizedBox(height: 5),
                                              Text(
                                                '${data.docs[index]['email']}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 70),
                                                child: Divider(
                                                  thickness: 1.5,
                                                  color: Colors.white,
                                                  height: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                  }
                                }
                                {
                                  return Container();
                                }
                              }),
                        );
                      }),
                ),
              SizedBox(height: 5),
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
              Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 18,
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
                              Icon(Icons.share_outlined),
                              SizedBox(width: 5),
                              Text(
                                'Shake the Link',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Share.share(widget.event.getEventId);
                          },
                        ),
                      ),
                      if (isManager)
                        Container(
                          height: MediaQuery.of(context).size.height / 18,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: Colors.white,
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
                                    'Scan Qr Code',
                                    style: TextStyle(
                                        color: Color(0xFF121B22), fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.qr_code_scanner,
                                    color: Color(0xFF121B22),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrScanPage(
                                            event: widget.event,
                                          )),
                                );
                              }),
                        ),
                      // if (!isManager)
                      //   FutureBuilder(
                      //     future: widget.databaseService
                      //         .getQrCodeByUserEvent(widget.event, userId),
                      //     initialData: "Loading text..",
                      //     builder:
                      //         (BuildContext context, AsyncSnapshot<String> text) {
                      //       return QrImage(
                      //         key: Key('qrCode'),
                      //         data: text.data!,
                      //         size: 200,
                      //         backgroundColor: Colors.white,
                      //       );
                      //     },
                      //   ),
                      if (!isManager)
                        Container(
                          height: MediaQuery.of(context).size.height / 18,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: Colors.white,
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
                                    'Show Qr Code',
                                    style: TextStyle(
                                        color: Color(0xFF121B22), fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Hero(
                                    tag: "hero1",
                                    // child: (FutureBuilder(
                                    //   future: widget.databaseService
                                    //       .getQrCodeByUserEvent(
                                    //           widget.event, userId),
                                    //   initialData: "Loading text..",
                                    //   builder: (BuildContext context,
                                    //       AsyncSnapshot<String> text) {
                                    //     return QrImage(
                                    //       size: 42,
                                    //       key: Key('qrCode'),
                                    //       data: text.data!,
                                    //       backgroundColor: Colors.white,
                                    //     );
                                    //   },
                                    // )),
                                    child: ClipOval(
                                      child: Icon(
                                        Icons.qr_code_2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                Navigator.of(context).push(
                                  PageRouteBuilder<Null>(
                                      pageBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double>
                                              secondaryAnimation) {
                                        return AnimatedBuilder(
                                            animation: animation,
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Opacity(
                                                opacity: animation.value,
                                                child: ShowQr(
                                                    event: widget.event,
                                                    authService: AuthService(
                                                        FirebaseAuth.instance),
                                                    databaseService:
                                                        DatabaseService(
                                                            AuthService(
                                                                    FirebaseAuth
                                                                        .instance)
                                                                .getCurrentUser()!
                                                                .uid,
                                                            FirebaseFirestore
                                                                .instance)),
                                              );
                                            });
                                      },
                                      transitionDuration:
                                          Duration(milliseconds: 1000)),
                                );
                              }),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
