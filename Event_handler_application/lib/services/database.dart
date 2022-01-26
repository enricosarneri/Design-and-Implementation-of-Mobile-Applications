import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/services/localization%20services/location_services.dart';
import 'package:event_handler/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class DatabaseService {
  final String uid;
  late final FirebaseFirestore firebaseFirestore;
  late final CollectionReference eventCollection;
  late final CollectionReference userQrCodesCollection;
  late final CollectionReference ownerLocals;

  late final CollectionReference userCollection;
  DatabaseService(this.uid, this.firebaseFirestore) {
    userCollection = firebaseFirestore.collection('users');
    eventCollection = firebaseFirestore.collection('events');
    userQrCodesCollection = firebaseFirestore.collection('userQrCodes');
    ownerLocals = firebaseFirestore.collection('ownerLocals');
  }

  Future updateUserData(String email, String password, String name,
      String surname, bool isOwner) async {
    return await userCollection.doc(uid).set({
      'email': email,
      'password': password,
      'name': name,
      'surname': surname,
      'isowner': isOwner,
    });
  }

  Stream<QuerySnapshot> getEvents() {
    return eventCollection.snapshots();
  }

  Stream<QuerySnapshot> getUsers() {
    return userCollection.snapshots();
  }

  Stream<QuerySnapshot> getUserQrCodes() {
    return userQrCodesCollection.snapshots();
  }

  List<Event> eventListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      return Event(
        e.get('manager'),
        e.get('name'),
        e.get('urlImage'),
        e.get('description'),
        e.get('latitude'),
        e.get('longitude'),
        e.get('placeName'),
        e.get('typeOfPlace'),
        e.get('eventType'),
        e.get('dateBegin'),
        e.get('dateEnd'),
        e.get('maxPartecipants'),
        e.get('price'),
        e.get('eventId'),
        List<String>.from(e.get('partecipants')),
        List<String>.from(e.get('applicants')),
        List<String>.from(e.get('qrCodeList')),
        e.get('firstFreeQrCode'),
      );
    }).toList();
  }

  Stream<List<Event>> get events {
    return eventCollection.snapshots().map(eventListFromSnapshot);
  }

  Future<AppUser> getCurrentUser() async {
    DocumentSnapshot? user;
    await userCollection.doc(uid).get().then((value) {
      user = value;
    });
    AppUser appUser = AppUser.fromAppUser(uid, user!['email'], user!['name'],
        user!['surname'], user!['password'], user!['isowner']);
    log("Current logged user: " + appUser.name);
    return appUser;
  }

  Future createEventData(
    String name,
    String urlImage,
    String description,
    String address,
    String placeName,
    String? typeOfPlace,
    String? eventType,
    DateTime? dateBegin,
    DateTime? dateEnd,
    String maxPartecipants,
    String price,
    int firstFreeQrCode,
    String? localName,
  ) async {
    List<String> partecipants = [];
    List<String> applicants = [];
    List<String> qrCodes = getRandomQrCodes(int.parse(maxPartecipants));
    String eventId = name + DateTime.now().microsecondsSinceEpoch.toString();

    String owner = '';
    double latitude = 0;
    double longitude = 0;
    String localAddress = '';
    await ownerLocals.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('localName') == localName &&
                  value.docs[i].get('owner') == uid)
                {
                  owner = uid,
                  localAddress = value.docs[i].get('localAddress'),
                  latitude = value.docs[i].get('latitude'),
                  longitude = value.docs[i].get('longitude'),
                }
            }
        });

    Event event = Event(
        uid,
        name,
        urlImage,
        description,
        latitude,
        longitude,
        placeName,
        typeOfPlace!,
        eventType!,
        dateBegin.toString(),
        dateEnd.toString(),
        int.parse(maxPartecipants),
        double.parse(price),
        eventId,
        partecipants,
        applicants,
        qrCodes,
        firstFreeQrCode);
    return await eventCollection.add({
      'manager': uid,
      'name': event.name,
      'urlImage': event.urlImage,
      'description': event.description,
      'latitude': latitude,
      'longitude': longitude,
      'placeName': localName,
      'typeOfPlace': event.typeOfPlace,
      'eventType': event.eventType,
      'dateBegin': event.dateBegin,
      'dateEnd': event.dateEnd,
      'maxPartecipants': event.maxPartecipants,
      'price': event.price,
      'qrCodeList': qrCodes,
      'partecipants': event.partecipants,
      'applicants': event.applicants,
      'eventId': event.eventId,
      'firstFreeQrCode': event.firstFreeQrCode,
    });
  }

  Future addLocalForCurrentUser(String localAddress, String localName) async {
    Coordinates coordinates =
        await LocationService().getCoordinatesByAddress(localAddress);
    return await ownerLocals.add({
      'owner': uid,
      'localName': localName,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'localAddress': localAddress,
    });
  }

  void addEventApplicant(Event event) async {
    List<String> applicantsList = event.getApplicantList;

    if (!applicantsList.contains(uid)) {
      applicantsList.add(uid);
      eventCollection.get().then((value) => {
            for (var i = 0; i < value.size; i++)
              {
                if (value.docs[i].get('eventId') == event.eventId)
                  {
                    eventCollection.doc(value.docs[i].id).update({
                      'applicants': event.applicants,
                    })
                  }
              }
          });
    }
  }

  List<String> getRandomQrCodes(int quantity) {
    var uuid = Uuid();
    List<String> qrCodeList = [];
    for (var i = 0; i < quantity; i++) {
      qrCodeList.add(uuid.v1());
    }
    return qrCodeList;
  }

  void acceptApplicance(Event event, String userId) async {
    List<String> applicantsList = event.getApplicantList;
    applicantsList.remove(userId);
    List<String> partecipants = event.getPartecipantList;
    partecipants.add(userId);
    eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId &&
                  value.docs[i].get('manager') != userId)
                {
                  eventCollection.doc(value.docs[i].id).update({
                    'partecipants': partecipants,
                    'applicants': applicantsList,
                    'firstFreeQrCode': event.firstFreeQrCode++,
                  })
                }
            }
        });
    log(event.firstFreeQrCode.toString());
    String userQrCode = event.getQrCodeList[event.firstFreeQrCode];
    await userQrCodesCollection
        .add({'user': userId, 'event': event.getEventId, 'qrCode': userQrCode});
  }

  void refuseApplicance(Event event, String userId) async {
    List<String> applicantsList = event.getApplicantList;
    applicantsList.remove(userId);
    eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId &&
                  value.docs[i].get('manager') != userId)
                {
                  eventCollection.doc(value.docs[i].id).update({
                    'applicants': applicantsList,
                  })
                }
            }
        });
  }

  Future<String> getQrCodeByUserEvent(Event event, String userId) async {
    String qrCode = '';
    await userQrCodesCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('event') == event.getEventId &&
                  value.docs[i].get('user') == userId)
                {qrCode = value.docs[i].get('qrCode')}
            }
        });
    return qrCode;
  }

  Future<Event> getEventByid(String eventid) async {
    String managerId = '';
    String name = '';
    String urlImage = '';
    String description = '';
    double latitude = 0;
    double longitude = 0;
    String placeName = '';
    String typeOfPlace = '';
    String eventType = '';
    String dateBegin = '';
    String dateEnd = '';
    int maxPartecipants = 0;

    double price = 0;
    String eventId = '';
    int firstFreeQrCode = 0;
    List<String> partecipants = [];
    List<String> applicants = [];
    List<String> qrCodes = [];
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == eventid)
                {
                  managerId = value.docs[i].get('manager'),
                  name = value.docs[i].get('name'),
                  urlImage = value.docs[i].get('urlImage'),
                  description = value.docs[i].get('description'),
                  latitude = value.docs[i].get('latitude'),
                  longitude = value.docs[i].get('longitude'),
                  placeName = value.docs[i].get('placeName'),
                  typeOfPlace = value.docs[i].get('typeOfPlace'),
                  eventType = value.docs[i].get('eventType'),
                  dateBegin = value.docs[i].get('dateBegin'),
                  dateEnd = value.docs[i].get('dateEnd'),
                  maxPartecipants = value.docs[i].get('maxPartecipants'),
                  price = value.docs[i].get('price'),
                  eventId = eventid,
                  firstFreeQrCode = value.docs[i].get('firstFreeQrCode'),
                  partecipants =
                      List<String>.from(value.docs[i].get('partecipants')),
                  applicants =
                      List<String>.from(value.docs[i].get('applicants')),
                  qrCodes = List<String>.from(value.docs[i].get('qrCodeList')),
                }
            }
        });
    Event event = Event(
        managerId,
        name,
        urlImage,
        description,
        latitude,
        longitude,
        placeName,
        typeOfPlace,
        eventType,
        dateBegin,
        dateEnd,
        maxPartecipants,
        price,
        eventId,
        partecipants,
        applicants,
        qrCodes,
        firstFreeQrCode);
    return event;
  }

  Future<List<Local>> getMyLocals() async {
    List<Local> locals = [];
    await ownerLocals.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('owner') == uid)
                {
                  locals.add(Local(
                      uid,
                      value.docs[i].get('localName'),
                      value.docs[i].get('localAddress'),
                      value.docs[i].get('latitude'),
                      value.docs[i].get('longitude')))
                }
            }
        });
    return locals;
  }

  Future<bool> isCurrentUserManager() async {
    bool isManager = false;
    await userCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].id == uid)
                {isManager = value.docs[i].get('isowner')}
            }
        });
    log("is manager= " + isManager.toString());
    return isManager;
  }

  Future<AppUser> getCurrentAppUser() async {
    String email = '';
    bool isOwner = false;
    String name = '';
    String password = '';
    String surname = '';

    await userCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].id == uid)
                {
                  isOwner = value.docs[i].get('isowner'),
                  email = value.docs[i].get('email'),
                  name = value.docs[i].get('name'),
                  password = value.docs[i].get('password'),
                  surname = value.docs[i].get('surname'),
                }
            }
        });
    return AppUser.fromAppUser(uid, email, name, surname, password, isOwner);
  }
}
