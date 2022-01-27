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
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 32),
          ),
        ),
        FutureBuilder(
          future: DatabaseService(
                  authService.getCurrentUser()!.uid, FirebaseFirestore.instance)
              .getMyLocals(),
          builder: (BuildContext context, AsyncSnapshot<List<Local>> myLocals) {
            return Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4.9),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    if (myLocals.data != null)
                      for (int i = 0; i < myLocals.data!.length; i++)
                        if (myLocals.data![i].localName == event.placeName)
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
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.4),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.place,
                      color: Colors.white,
                    ),
                    Text(
                      event.placeName,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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
                    color: Colors.white,
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
                    width: 5,
                  ),
                  Text(
                    event.dateBegin.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
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
                    color: Colors.white,
                    height: 15,
                  ),
                ),
              ),
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
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
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
                    color: Colors.white,
                    height: 15,
                  ),
                ),
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
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
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
                    margin: EdgeInsets.only(top: 20),
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
                        controller: ScrollController(),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        children: [
                          Text(
                            event.description,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
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
                                  padding: EdgeInsets.symmetric(vertical: 5),
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
                            Share.share(event.getEventId);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
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
                              Icon(Icons.notifications,
                                  color: Color(0xFF121B22)),
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
                        Share.share(event.getEventId);
                      },
                    ),
                  ),
                ),
              if (partecipantList.contains(authService.getCurrentUser()!.uid))
                Container(
                  child: Text("You're already partecipating to this event",
                      style: TextStyle(color: Colors.white)),
                ),
              if (applicantList.contains(authService.getCurrentUser()!.uid))
                Container(
                  child: Text("Waiting for the response of the owner",
                      style: TextStyle(color: Colors.white)),
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
              style: TextStyle(fontWeight: FontWeight.w400),
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
