import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:image_downloader/image_downloader.dart';
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
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> events = DatabaseService(
            _authService.getCurrentUser()!.uid, FirebaseFirestore.instance)
        .getEvents();
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
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              offset: const Offset(0, 8),
                              blurRadius: 6.0,
                              spreadRadius: 0)
                        ]),
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
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [0, 0.9],
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
                return Center(
                  child: CircularProgressIndicator(),
                );
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
          alignment: Alignment.topLeft,
          height: MediaQuery.of(context).size.height / 20,
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 7),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            event.name,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 32),
          ),
        ),
        FutureBuilder(
          future: DatabaseService(_authService.getCurrentUser()!.uid,
                  FirebaseFirestore.instance)
              .getMyLocals(),
          builder: (BuildContext context, AsyncSnapshot<List<Local>> myLocals) {
            return Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 5),
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
                                color: Colors.white),
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
                  color: Colors.grey.shade100,
                ),
                child: Row(
                  children: [
                    IconShadowWidget(
                      Icon(
                        Icons.place,
                      ),
                      shadowColor: Colors.black12,
                    ),
                    Text(
                      event.placeName,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Divider(
                    color: Colors.black45.withOpacity(0.2),
                    height: 15,
                  ),
                ),
              ),
              Row(
                children: [
                  IconShadowWidget(
                    Icon(Icons.date_range),
                    shadowColor: Colors.black12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    event.date.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        fontSize: 16),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Divider(
                    color: Colors.black45.withOpacity(0.2),
                    height: 15,
                  ),
                ),
              ),
              Row(
                children: [
                  IconShadowWidget(
                    Icon(Icons.people),
                    shadowColor: Colors.black12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    event.partecipants.length.toString() +
                        "/" +
                        event.maxPartecipants.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Divider(
                    color: Colors.black45.withOpacity(0.2),
                    height: 15,
                  ),
                ),
              ),
              Row(
                children: [
                  IconShadowWidget(
                    Icon(Icons.euro),
                    shadowColor: Colors.black12,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    event.price.toString() + " €",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  child: Divider(
                    color: Colors.black45.withOpacity(0.2),
                    height: 15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200.withOpacity(0.5),
                      ),
                      height: MediaQuery.of(context).size.height / 10,
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: Scrollbar(
                        isAlwaysShown: true,
                        thickness: 10,
                        child: ListView(
                          controller: ScrollController(),
                          padding: EdgeInsets.all(8),
                          children: [
                            Text(
                              event.description,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  width: 30,
                  height: 1,
                  decoration: BoxDecoration(
                    color: Colors.black45.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: MediaQuery.of(context).size.height / 16,
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
                    child: Text(
                      'Ask to Partecipate',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      final AuthService _authService =
                          AuthService(FirebaseAuth.instance);
                      DatabaseService(_authService.getCurrentUser()!.uid,
                              FirebaseFirestore.instance)
                          .addEventApplicant(event);
                      //oppure mostrare un messagio con scritto Richiesta inviata con successo
                      panelController.close();
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
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: tooglePanel,
      );

  void tooglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();
}
