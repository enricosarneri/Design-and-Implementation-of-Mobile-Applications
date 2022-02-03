import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/services/database%20services/database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PanelWidget extends StatelessWidget {
  PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
    required this.event,
  }) : super(key: key);
  final ScrollController controller;
  final PanelController panelController;
  final Event event;
  final AuthService authService = AuthService(FirebaseAuth.instance);

  // @override
  // _PanelState createState() => _PanelState();
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = DatabaseService(
            authService.getCurrentUser()!.uid, FirebaseFirestore.instance)
        .getEvents();
    List<String> partecipantList = event.getPartecipantList;
    List<String> applicantList = event.getApplicantList;
    log(event.urlImage.toString());
    return Stack(
      children: <Widget>[
        StreamBuilder(
          stream: events,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('loading');
            }
            final data = snapshot.requireData;
            return ListView.builder(
              padding: EdgeInsets.all(0),
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: false,
              itemCount: data.size,
              itemBuilder: (context, index) {
                if (data.docs[index]['urlImage'] == event.getUrlImage) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // boxShadow: [
                      //   BoxShadow(
                      //       color: Colors.grey.withOpacity(0.6),
                      //       offset: const Offset(0, 8),
                      //       blurRadius: 6.0,
                      //       spreadRadius: 0)
                      // ],
                    ),
                    height: MediaQuery.of(context).size.height / 4 +
                        MediaQuery.of(context).size.height / 40,
                    //   margin: EdgeInsets.only(top: 7, right: 5, left: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                              Colors.black38,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [0, 0.5, 0.9],
                          ),
                        ),
                        child: Image.network(
                          data.docs[index]['urlImage'],
                          fit: BoxFit.cover,
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
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height / 25,
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 70),
          child: buildDragHandle(),
        ),
        Container(
          color: Colors.transparent,
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height / 20,
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 6.5),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            event.name,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width > 900 ? 36 : 32),
          ),
        ),
        FutureBuilder(
          future: DatabaseService(
                  authService.getCurrentUser()!.uid, FirebaseFirestore.instance)
              .getTotalLocals(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Local>> totalLocals) {
            return Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4.9),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    if (totalLocals.data != null)
                      for (int i = 0; i < totalLocals.data!.length; i++)
                        if (totalLocals.data![i].latitude == event.latitude &&
                            totalLocals.data![i].longitude == event.longitude)
                          Text(
                            totalLocals.data![i].localAddress,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: MediaQuery.of(context).size.width > 900
                                  ? 20
                                  : 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ],
                ));
          },
        ),
        Container(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width > 900 ? 300 : 10,
              right: MediaQuery.of(context).size.width > 900 ? 300 : 10),
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.4),
          child: Column(
            children: [
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),

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
                    event.placeName,
                    style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 900 ? 18 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(

              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Divider(
                    thickness: 1,
                    color: Colors.white.withOpacity(0.6),
                    height: 15,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "From: ",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    TextSpan(
                      text: event.dateBegin.isEmpty
                          ? ""
                          : event.dateBegin.substring(0, 10) +
                              " " +
                              event.dateBegin.substring(11, 16),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    // TextSpan(
                    //   text: " at ",
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w300),
                    // ),
                    // TextSpan(
                    //   text: DateTime.tryParse(event.dateBegin)
                    //       .toString()
                    //       .substring(11, 16),
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w600),
                    // ),
                  ]))
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "To: ",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    TextSpan(
                      text: event.dateEnd.isEmpty
                          ? ""
                          : event.dateEnd.substring(0, 10) +
                              " " +
                              event.dateEnd.substring(11, 16),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    // TextSpan(
                    //   text: " at: ",
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w300),
                    // ),
                    // TextSpan(
                    //   // text: DateTime.tryParse(event.dateEnd)
                    //   //     .toString()
                    //   //     .substring(11, 16),
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w600),
                    // ),
                  ]))
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Divider(
                    thickness: 1,
                    color: Colors.white.withOpacity(0.6),
                    height: 15,
                  ),
                ),
              ),
              if (!partecipantList
                      .contains(authService.getCurrentUser()!.uid) &&
                  !applicantList.contains(authService.getCurrentUser()!.uid))
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
                      event.partecipants.length.toString() +
                          "/" +
                          event.maxPartecipants.toString(),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              if (partecipantList.contains(authService.getCurrentUser()!.uid) ||
                  applicantList.contains(authService.getCurrentUser()!.uid))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                          event.partecipants.length.toString() +
                              "/" +
                              event.maxPartecipants.toString(),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 900
                                  ? 18
                                  : 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.euro,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          event.price.toString() + " €",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 900
                                  ? 18
                                  : 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Divider(
                    thickness: 1,
                    color: Colors.white.withOpacity(0.6),
                    height: 15,
                  ),
                ),
              ),

              if (!partecipantList
                      .contains(authService.getCurrentUser()!.uid) &&
                  !applicantList.contains(authService.getCurrentUser()!.uid))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.euro,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      event.price.toString() + " €",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),

              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(
              //         top: 5,
              //         bottom: 15,
              //         left: 30,
              //         right: MediaQuery.of(context).size.width / 3),
              //     child: Divider(
              //       thickness: 1,
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),
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
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            controller: ScrollController(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            children: [
                              Text(
                                event.description,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 900
                                            ? 16
                                            : 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (partecipantList.contains(authService.getCurrentUser()!.uid) ||
                  applicantList.contains(authService.getCurrentUser()!.uid))
                SizedBox(
                  height: MediaQuery.of(context).size.width > 900 ? 15 : 10,
                ),

              if (partecipantList.contains(authService.getCurrentUser()!.uid))
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("You're already partecipating to this event!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width > 900
                                  ? 16
                                  : 14)),
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              if (applicantList.contains(authService.getCurrentUser()!.uid))
                Container(
                  child: Text("Waiting for the response of the owner!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 900
                              ? 16
                              : 14)),
                ),
              if (!partecipantList
                      .contains(authService.getCurrentUser()!.uid) &&
                  !applicantList.contains(authService.getCurrentUser()!.uid))
                SizedBox(
                  height: MediaQuery.of(context).size.width > 900 ? 20 : 15,
                ),
              if (partecipantList.contains(authService.getCurrentUser()!.uid) ||
                  applicantList.contains(authService.getCurrentUser()!.uid))
                SizedBox(
                  height: MediaQuery.of(context).size.width > 900 ? 15 : 10,
                ),
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

              SizedBox(
                height: MediaQuery.of(context).size.width > 900 ? 15 : 10,
              ),
              //You will not see the partecipate button if you're the owener of the event or the partecipants reach the maxNumber
              if (event.getManagerId != authService.getCurrentUser()!.uid &&
                  event.firstFreeQrCode + 1 != event.getMaxPartecipants &&
                  !partecipantList
                      .contains(authService.getCurrentUser()!.uid) &&
                  !applicantList.contains(authService.getCurrentUser()!.uid))
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Share the Link',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    900
                                                ? 18
                                                : 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Share.share(event.getEventId);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Expanded(
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
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.width >
                                                  900
                                              ? 15
                                              : 5),
                                  child: Container(
                                    child: Text(
                                      'Ask to Partecipate',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF121B22),
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  900
                                              ? 18
                                              : 16),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.notifications,
                                color: Color(0xFF121B22),
                                size: 20,
                              ),
                            ],
                          ),
                          onPressed: () async {
                            final AuthService _authService =
                                AuthService(FirebaseAuth.instance);
                            DatabaseService(_authService.getCurrentUser()!.uid,
                                    FirebaseFirestore.instance)
                                .addEventApplicant(event);
                            //oppure mostrare un messagio con scritto Richiesta inviata con successo
                            panelController.close();
                            Fluttertoast.showToast(
                                msg:
                                    "You've succesfully applied for the event!",
                                gravity: ToastGravity.CENTER);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (!(event.getManagerId != authService.getCurrentUser()!.uid &&
                  event.firstFreeQrCode + 1 != event.getMaxPartecipants &&
                  !partecipantList
                      .contains(authService.getCurrentUser()!.uid) &&
                  !applicantList.contains(authService.getCurrentUser()!.uid)))
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(context).size.width > 900 ? 200 : 80),
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
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Share the Link',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 900
                                            ? 18
                                            : 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Share.share(event.getEventId);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAboutText() => Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              event.name,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            Text(
              'description ' + event.description,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'max partecipants: ' + event.maxPartecipants.toString(),
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );

  Widget buildDragHandle() => GestureDetector(
        child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: tooglePanel,
      );

  void tooglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();
}

// class _PanelState extends State<PanelWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth > 900) {
//             return WideLayout(
//               controller: widget.controller,
//               panelController: widget.panelController,
//               event: widget.event,
//               authService: widget.authService,
//             );
//           } else {
//             return NarrowLayout(
//               controller: widget.controller,
//               panelController: widget.panelController,
//               event: widget.event,
//               authService: widget.authService,
//             );
//           }
//         },
//       ),
//     );
//   }
// }

class NarrowLayout extends StatefulWidget {
  final ScrollController? controller;
  final PanelController? panelController;
  final Event? event;
  final AuthService? authService;
  @override
  NarrowLayout(
      {Key? key,
      this.controller,
      this.panelController,
      this.event,
      this.authService})
      : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = DatabaseService(
            widget.authService!.getCurrentUser()!.uid,
            FirebaseFirestore.instance)
        .getEvents();
    List<String> partecipantList = widget.event!.getPartecipantList;
    List<String> applicantList = widget.event!.getApplicantList;
    log(widget.event!.urlImage.toString());
    return Stack(
      children: <Widget>[
        StreamBuilder(
          stream: events,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('loading');
            }
            final data = snapshot.requireData;
            return ListView.builder(
              padding: EdgeInsets.all(0),
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: false,
              itemCount: data.size,
              itemBuilder: (context, index) {
                if (data.docs[index]['urlImage'] == widget.event!.getUrlImage) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // boxShadow: [
                      //   BoxShadow(
                      //       color: Colors.grey.withOpacity(0.6),
                      //       offset: const Offset(0, 8),
                      //       blurRadius: 6.0,
                      //       spreadRadius: 0)
                      // ],
                    ),
                    height: MediaQuery.of(context).size.height / 4 +
                        MediaQuery.of(context).size.height / 40,
                    //   margin: EdgeInsets.only(top: 7, right: 5, left: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                              Colors.black38,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [0, 0.5, 0.9],
                          ),
                        ),
                        child: Image.network(
                          data.docs[index]['urlImage'],
                          fit: BoxFit.cover,
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
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height / 25,
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 70),
          child: buildDragHandle(),
        ),
        Container(
          color: Colors.transparent,
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height / 20,
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 6.5),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.event!.name,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 32),
          ),
        ),
        FutureBuilder(
          future: DatabaseService(widget.authService!.getCurrentUser()!.uid,
                  FirebaseFirestore.instance)
              .getTotalLocals(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Local>> totalLocals) {
            return Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4.9),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    if (totalLocals.data != null)
                      for (int i = 0; i < totalLocals.data!.length; i++)
                        if (totalLocals.data![i].latitude ==
                                widget.event!.latitude &&
                            totalLocals.data![i].longitude ==
                                widget.event!.longitude)
                          Text(
                            totalLocals.data![i].localAddress,
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
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.4),
          child: Column(
            children: [
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),

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
                    widget.event!.placeName,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Divider(
                    thickness: 1,
                    color: Colors.white.withOpacity(0.6),
                    height: 15,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "From: ",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    TextSpan(
                      text: widget.event!.dateBegin.isEmpty
                          ? ""
                          : widget.event!.dateBegin.substring(0, 10) +
                              " " +
                              widget.event!.dateBegin.substring(11, 16),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    // TextSpan(
                    //   text: " at ",
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w300),
                    // ),
                    // TextSpan(
                    //   text: DateTime.tryParse(event.dateBegin)
                    //       .toString()
                    //       .substring(11, 16),
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w600),
                    // ),
                  ]))
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.date_range,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "From: ",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                    TextSpan(
                      text: widget.event!.dateEnd.isEmpty
                          ? ""
                          : widget.event!.dateEnd.substring(0, 10) +
                              " " +
                              widget.event!.dateEnd.substring(11, 16),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 900 ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    // TextSpan(
                    //   text: " at ",
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w300),
                    // ),
                    // TextSpan(
                    //   text: DateTime.tryParse(event.dateBegin)
                    //       .toString()
                    //       .substring(11, 16),
                    //   style: TextStyle(
                    //       fontSize:
                    //           MediaQuery.of(context).size.width > 900 ? 18 : 16,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w600),
                    // ),
                  ]))
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Divider(
                    thickness: 1,
                    color: Colors.white.withOpacity(0.6),
                    height: 15,
                  ),
                ),
              ),
              if (!partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) &&
                  !applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
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
                      widget.event!.partecipants.length.toString() +
                          "/" +
                          widget.event!.maxPartecipants.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              if (partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) ||
                  applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                          widget.event!.partecipants.length.toString() +
                              "/" +
                              widget.event!.maxPartecipants.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.euro,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.event!.price.toString() + " €",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),

              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Divider(
                    thickness: 1,
                    color: Colors.white.withOpacity(0.6),
                    height: 15,
                  ),
                ),
              ),

              if (!partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) &&
                  !applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.euro,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.event!.price.toString() + " €",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),

              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     width: MediaQuery.of(context).size.width / 2,
              //     child: Divider(
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Container(
              //     margin: EdgeInsets.only(
              //         top: 5,
              //         bottom: 15,
              //         left: 30,
              //         right: MediaQuery.of(context).size.width / 3),
              //     child: Divider(
              //       thickness: 1,
              //       color: Colors.white,
              //       height: 15,
              //     ),
              //   ),
              // ),
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
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            controller: ScrollController(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            children: [
                              Text(
                                widget.event!.description,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) ||
                  applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
                SizedBox(
                  height: 10,
                ),

              if (partecipantList
                  .contains(widget.authService!.getCurrentUser()!.uid))
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("You're already partecipating to this event!",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              if (applicantList
                  .contains(widget.authService!.getCurrentUser()!.uid))
                Container(
                  child: Text("Waiting for the response of the owner!",
                      style: TextStyle(color: Colors.white)),
                ),
              if (!partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) &&
                  !applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
                SizedBox(
                  height: 15,
                ),
              if (partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) ||
                  applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              //You will not see the partecipate button if you're the owener of the event or the partecipants reach the maxNumber
              if (widget.event!.getManagerId !=
                      widget.authService!.getCurrentUser()!.uid &&
                  widget.event!.firstFreeQrCode + 1 !=
                      widget.event!.getMaxPartecipants &&
                  !partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) &&
                  !applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid))
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Share the Link',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Share.share(widget.event!.getEventId);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Expanded(
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
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Container(
                                    child: Text(
                                      'Ask to Partecipate',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF121B22),
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.notifications,
                                color: Color(0xFF121B22),
                                size: 20,
                              ),
                            ],
                          ),
                          onPressed: () async {
                            final AuthService _authService =
                                AuthService(FirebaseAuth.instance);
                            DatabaseService(_authService.getCurrentUser()!.uid,
                                    FirebaseFirestore.instance)
                                .addEventApplicant(widget.event!);
                            //oppure mostrare un messagio con scritto Richiesta inviata con successo
                            widget.panelController!.close();
                            Fluttertoast.showToast(
                                msg:
                                    "You've succesfully applied for the event!",
                                gravity: ToastGravity.CENTER);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (!(widget.event!.getManagerId !=
                      widget.authService!.getCurrentUser()!.uid &&
                  widget.event!.firstFreeQrCode + 1 !=
                      widget.event!.getMaxPartecipants &&
                  !partecipantList
                      .contains(widget.authService!.getCurrentUser()!.uid) &&
                  !applicantList
                      .contains(widget.authService!.getCurrentUser()!.uid)))
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 80),
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
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Share the Link',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Share.share(widget.event!.getEventId);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAboutText() => Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.event!.name,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            Text(
              'description ' + widget.event!.description,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 24),
            Text(
              'max partecipants: ' + widget.event!.maxPartecipants.toString(),
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );

  Widget buildDragHandle() => GestureDetector(
        child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: tooglePanel,
      );

  void tooglePanel() => widget.panelController!.isPanelOpen
      ? widget.panelController!.close()
      : widget.panelController!.open();
}

// class WideLayout extends StatefulWidget {
//   final ScrollController? controller;
//   final PanelController? panelController;
//   final Event? event;
//   final AuthService? authService;
//   @override
//   WideLayout(
//       {Key? key,
//       this.controller,
//       this.panelController,
//       this.event,
//       this.authService})
//       : super(key: key);
//   _WideLayoutState createState() => _WideLayoutState();
// }

// class _WideLayoutState extends State<WideLayout> {
//   @override
//   Widget build(BuildContext context) {
//     Stream<QuerySnapshot> events = DatabaseService(
//             widget.authService!.getCurrentUser()!.uid,
//             FirebaseFirestore.instance)
//         .getEvents();
//     List<String> partecipantList = widget.event!.getPartecipantList;
//     List<String> applicantList = widget.event!.getApplicantList;
//     log(widget.event!.urlImage.toString());
//     return Stack(
//       children: <Widget>[
//         StreamBuilder(
//           stream: events,
//           builder:
//               (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.hasError) {
//               return Text('something went wrong');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Text('loading');
//             }
//             final data = snapshot.requireData;
//             return ListView.builder(
//               padding: EdgeInsets.all(0),
//               physics: NeverScrollableScrollPhysics(),
//               scrollDirection: Axis.vertical,
//               shrinkWrap: false,
//               itemCount: data.size,
//               itemBuilder: (context, index) {
//                 if (data.docs[index]['urlImage'] == widget.event!.getUrlImage) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       // boxShadow: [
//                       //   BoxShadow(
//                       //       color: Colors.grey.withOpacity(0.6),
//                       //       offset: const Offset(0, 8),
//                       //       blurRadius: 6.0,
//                       //       spreadRadius: 0)
//                       // ],
//                     ),
//                     height: MediaQuery.of(context).size.height / 4 +
//                         MediaQuery.of(context).size.height / 40,
//                     //   margin: EdgeInsets.only(top: 7, right: 5, left: 5),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                         bottomLeft: Radius.circular(20),
//                         bottomRight: Radius.circular(20),
//                       ),
//                       child: Container(
//                         foregroundDecoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.black87,
//                               Colors.transparent,
//                               Colors.black38,
//                             ],
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                             stops: [0, 0.5, 0.9],
//                           ),
//                         ),
//                         child: Image.network(
//                           data.docs[index]['urlImage'],
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 return Center();
//               },
//             );
//           },
//         ),
//         Container(
//           alignment: Alignment.topCenter,
//           height: MediaQuery.of(context).size.height / 25,
//           margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 70),
//           child: buildDragHandle(),
//         ),
//         Container(
//           color: Colors.transparent,
//           alignment: Alignment.topCenter,
//           height: MediaQuery.of(context).size.height / 20,
//           margin:
//               EdgeInsets.only(top: MediaQuery.of(context).size.height / 6.5),
//           padding: EdgeInsets.symmetric(horizontal: 8),
//           child: Text(
//             widget.event!.name,
//             style: TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.w600, fontSize: 32),
//           ),
//         ),
//         FutureBuilder(
//           future: DatabaseService(widget.authService!.getCurrentUser()!.uid,
//                   FirebaseFirestore.instance)
//               .getTotalLocals(),
//           builder:
//               (BuildContext context, AsyncSnapshot<List<Local>> totalLocals) {
//             return Container(
//                 alignment: Alignment.topCenter,
//                 margin: EdgeInsets.only(
//                     top: MediaQuery.of(context).size.height / 4.9),
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Column(
//                   children: [
//                     if (totalLocals.data != null)
//                       for (int i = 0; i < totalLocals.data!.length; i++)
//                         if (totalLocals.data![i].latitude ==
//                                 widget.event!.latitude &&
//                             totalLocals.data![i].longitude ==
//                                 widget.event!.longitude)
//                           Text(
//                             totalLocals.data![i].localAddress,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w300,
//                               fontSize: 16,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                   ],
//                 ));
//           },
//         ),
//         Container(
//           padding: EdgeInsets.only(left: 10, right: 10),
//           margin:
//               EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.4),
//           child: Column(
//             children: [
//               // Align(
//               //   alignment: Alignment.topLeft,
//               //   child: Container(
//               //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
//               //     decoration: BoxDecoration(
//               //       borderRadius: BorderRadius.circular(20),
//               //     ),
//               //     width: MediaQuery.of(context).size.width / 2,
//               //     child: Divider(
//               //       color: Colors.white,
//               //       height: 15,
//               //     ),
//               //   ),
//               // ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.place,
//                     color: Colors.white,
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Text(
//                     widget.event!.placeName,
//                     style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w300),
//                   ),
//                 ],
//               ),
//               // Align(
//               //   alignment: Alignment.topLeft,
//               //   child: Container(
//               //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
//               //     decoration: BoxDecoration(
//               //       borderRadius: BorderRadius.circular(20),
//               //     ),
//               //     width: MediaQuery.of(context).size.width / 2,
//               //     child: Divider(
//               //       color: Colors.white,
//               //       height: 15,
//               //     ),
//               //   ),
//               // ),
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   margin: EdgeInsets.only(
//                     top: 5,
//                     bottom: 5,
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 60),
//                   child: Divider(
//                     thickness: 1,
//                     color: Colors.white.withOpacity(0.6),
//                     height: 15,
//                   ),
//                 ),
//               ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     TextSpan(
//                       text: "From: ",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300),
//                     ),
//                     TextSpan(
//                       // text: DateTime.tryParse(event.dateBegin)
//                       //     .toString()
//                       //     .substring(0, 10),
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     TextSpan(
//                       text: " at ",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300),
//                     ),
//                     TextSpan(
//                       // text: DateTime.tryParse(event.dateBegin)
//                       //     .toString()
//                       //     .substring(11, 16),
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ]))
//                 ],
//               ),
//               SizedBox(
//                 height: 2,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     TextSpan(
//                       text: "To: ",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300),
//                     ),
//                     TextSpan(
//                       // text: DateTime.tryParse(event.dateEnd)
//                       //     .toString()
//                       //     .substring(0, 10),
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     TextSpan(
//                       text: " at: ",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300),
//                     ),
//                     TextSpan(
//                       // text: DateTime.tryParse(event.dateEnd)
//                       //     .toString()
//                       //     .substring(11, 16),
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ]))
//                 ],
//               ),
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   margin: EdgeInsets.only(
//                     top: 5,
//                     bottom: 5,
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 60),
//                   child: Divider(
//                     thickness: 1,
//                     color: Colors.white.withOpacity(0.6),
//                     height: 15,
//                   ),
//                 ),
//               ),
//               if (!partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) &&
//                   !applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.people,
//                       color: Colors.white,
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       widget.event!.partecipants.length.toString() +
//                           "/" +
//                           widget.event!.maxPartecipants.toString(),
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300),
//                     ),
//                   ],
//                 ),
//               if (partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) ||
//                   applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.people,
//                           color: Colors.white,
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         Text(
//                           widget.event!.partecipants.length.toString() +
//                               "/" +
//                               widget.event!.maxPartecipants.toString(),
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w300),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.euro,
//                           color: Colors.white,
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         Text(
//                           widget.event!.price.toString() + " €",
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w300),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               // Align(
//               //   alignment: Alignment.topLeft,
//               //   child: Container(
//               //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
//               //     decoration: BoxDecoration(
//               //       borderRadius: BorderRadius.circular(20),
//               //     ),
//               //     width: MediaQuery.of(context).size.width / 2,
//               //     child: Divider(
//               //       color: Colors.white,
//               //       height: 15,
//               //     ),
//               //   ),
//               // ),

//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   margin: EdgeInsets.only(
//                     top: 5,
//                     bottom: 5,
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 60),
//                   child: Divider(
//                     thickness: 1,
//                     color: Colors.white.withOpacity(0.6),
//                     height: 15,
//                   ),
//                 ),
//               ),

//               if (!partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) &&
//                   !applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.euro,
//                       color: Colors.white,
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       widget.event!.price.toString() + " €",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300),
//                     ),
//                   ],
//                 ),

//               // Align(
//               //   alignment: Alignment.topLeft,
//               //   child: Container(
//               //     margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
//               //     decoration: BoxDecoration(
//               //       borderRadius: BorderRadius.circular(20),
//               //     ),
//               //     width: MediaQuery.of(context).size.width / 2,
//               //     child: Divider(
//               //       color: Colors.white,
//               //       height: 15,
//               //     ),
//               //   ),
//               // ),
//               // Align(
//               //   alignment: Alignment.topLeft,
//               //   child: Container(
//               //     margin: EdgeInsets.only(
//               //         top: 5,
//               //         bottom: 15,
//               //         left: 30,
//               //         right: MediaQuery.of(context).size.width / 3),
//               //     child: Divider(
//               //       thickness: 1,
//               //       color: Colors.white,
//               //       height: 15,
//               //     ),
//               //   ),
//               // ),
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Container(
//                     margin: EdgeInsets.only(top: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.black12.withOpacity(0.4),
//                       border: Border.all(color: Colors.white),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     height: MediaQuery.of(context).size.height / 10,
//                     width: MediaQuery.of(context).size.width / 1.2,
//                     child: Scrollbar(
//                       isAlwaysShown: true,
//                       thickness: 10,
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(30)),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: ListView(
//                             scrollDirection: Axis.vertical,
//                             controller: ScrollController(),
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 8),
//                             children: [
//                               Text(
//                                 widget.event!.description,
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               if (partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) ||
//                   applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 SizedBox(
//                   height: 10,
//                 ),

//               if (partecipantList
//                   .contains(widget.authService!.getCurrentUser()!.uid))
//                 Container(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text("You're already partecipating to this event!",
//                           style: TextStyle(color: Colors.white)),
//                       SizedBox(
//                         width: 4,
//                       ),
//                       Icon(
//                         Icons.sentiment_satisfied_alt_outlined,
//                         color: Colors.white,
//                       ),
//                     ],
//                   ),
//                 ),
//               if (applicantList
//                   .contains(widget.authService!.getCurrentUser()!.uid))
//                 Container(
//                   child: Text("Waiting for the response of the owner!",
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               if (!partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) &&
//                   !applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 SizedBox(
//                   height: 15,
//                 ),
//               if (partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) ||
//                   applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 SizedBox(
//                   height: 10,
//                 ),
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   width: 30,
//                   height: 3,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),

//               SizedBox(
//                 height: 10,
//               ),
//               //You will not see the partecipate button if you're the owener of the event or the partecipants reach the maxNumber
//               if (widget.event!.getManagerId !=
//                       widget.authService!.getCurrentUser()!.uid &&
//                   widget.event!.firstFreeQrCode + 1 !=
//                       widget.event!.getMaxPartecipants &&
//                   !partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) &&
//                   !applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid))
//                 Flexible(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             elevation: 0,
//                             primary: Colors.transparent,
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: Colors.white,
//                               ),
//                               borderRadius: BorderRadius.circular(30.0),
//                             ),
//                             //  shadowColor: Colors.grey.shade400),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.share_outlined),
//                               SizedBox(width: 5),
//                               Flexible(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 14),
//                                   child: Text(
//                                     'Share the Link',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 16),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           onPressed: () {
//                             Share.share(widget.event!.getEventId);
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         width: 40,
//                       ),
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             primary: Colors.white,
//                             onPrimary: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                             ),
//                             // side: BorderSide(color: Colors.black)),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Flexible(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 5),
//                                   child: Container(
//                                     child: Text(
//                                       'Ask to Partecipate',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           color: Color(0xFF121B22),
//                                           fontSize: 16),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 5,
//                               ),
//                               Icon(
//                                 Icons.notifications,
//                                 color: Color(0xFF121B22),
//                                 size: 20,
//                               ),
//                             ],
//                           ),
//                           onPressed: () async {
//                             final AuthService _authService =
//                                 AuthService(FirebaseAuth.instance);
//                             DatabaseService(_authService.getCurrentUser()!.uid,
//                                     FirebaseFirestore.instance)
//                                 .addEventApplicant(widget.event!);
//                             //oppure mostrare un messagio con scritto Richiesta inviata con successo
//                             widget.panelController!.close();
//                             Fluttertoast.showToast(
//                                 msg:
//                                     "You've succesfully applied for the event!",
//                                 gravity: ToastGravity.CENTER);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (!(widget.event!.getManagerId !=
//                       widget.authService!.getCurrentUser()!.uid &&
//                   widget.event!.firstFreeQrCode + 1 !=
//                       widget.event!.getMaxPartecipants &&
//                   !partecipantList
//                       .contains(widget.authService!.getCurrentUser()!.uid) &&
//                   !applicantList
//                       .contains(widget.authService!.getCurrentUser()!.uid)))
//                 Flexible(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 80),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         primary: Colors.transparent,
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                             color: Colors.white,
//                           ),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         //  shadowColor: Colors.grey.shade400),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.share_outlined),
//                           SizedBox(width: 5),
//                           Flexible(
//                             child: Container(
//                               padding: EdgeInsets.symmetric(vertical: 12),
//                               child: Text(
//                                 'Share the Link',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 16),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       onPressed: () {
//                         Share.share(widget.event!.getEventId);
//                       },
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildAboutText() => Container(
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               widget.event!.name,
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'description ' + widget.event!.description,
//               style: TextStyle(fontWeight: FontWeight.w400),
//             ),
//             SizedBox(height: 24),
//             Text(
//               'max partecipants: ' + widget.event!.maxPartecipants.toString(),
//               style: TextStyle(fontWeight: FontWeight.w400),
//             ),
//           ],
//         ),
//       );

//   Widget buildDragHandle() => GestureDetector(
//         child: Container(
//           width: 30,
//           height: 5,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onTap: tooglePanel,
//       );

//   void tooglePanel() => widget.panelController!.isPanelOpen
//       ? widget.panelController!.close()
//       : widget.panelController!.open();
// }
