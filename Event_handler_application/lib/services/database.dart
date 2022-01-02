import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/services/localization%20services/location_services.dart';
import 'package:event_handler/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';


class DatabaseService {
  final String uid;
  DatabaseService(this.uid);
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection('events');
  final CollectionReference userQrCodesCollection= FirebaseFirestore.instance.collection('userQrCodes');

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
          e.get('description'),
          e.get('latitude'),
          e.get('longitude'),
          e.get('placeName'),
          e.get('eventType'),
          e.get('date'),
          e.get('maxPartecipants'),
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
      String description,
      String address,
      String placeName,
      String? eventType,
      DateTime? date,
      String maxPartecipants,
      int firstFreeQrCode,
      ) async {
      List<String> partecipants=[];
      List<String> applicants=[];
      List<String> qrCodes= getRandomQrCodes(int.parse(maxPartecipants));
      String eventId=  name+DateTime.now().microsecondsSinceEpoch.toString();
    Coordinates coordinates =
        await LocationService().getCoordinatesByAddress(address);
    Event event= Event(uid, name, description, coordinates.latitude, coordinates.longitude, placeName, eventType!, date.toString(), int.parse(maxPartecipants), eventId, partecipants, applicants,qrCodes,firstFreeQrCode);
    return await eventCollection.add({
      'manager': uid,
      'name': event.name,
      'description': event.description,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'placeName': event.placeName,
      'eventType': event.eventType,
      'date': event.date,
      'maxPartecipants': event.maxPartecipants,
      'qrCodeList' : qrCodes,
      'partecipants' : event.partecipants,
      'applicants' : event.applicants,
      'eventId' : event.eventId,
      'firstFreeQrCode' : event.firstFreeQrCode,
    });
  }

  void addEventApplicant(Event event) async{
    List<String> applicantsList=event.getApplicantList;
    applicantsList.add(uid);
    eventCollection.get().then((value) => {
      for (var i = 0; i < value.size; i++) {
        if(value.docs[i].get('eventId') == event.eventId) {
          eventCollection.doc(value.docs[i].id).update({
            'applicants' : event.applicants,
          })
        }
      }
    });
  }

  List<String> getRandomQrCodes(int quantity){
    var uuid= Uuid();
    List<String> qrCodeList=[];
    for (var i = 0; i < quantity; i++) {
      qrCodeList.add(uuid.v1());
    }
    return qrCodeList;
  }

  void acceptApplicance(Event event, String userId) async{
    List<String> applicantsList=event.getApplicantList;
    applicantsList.remove(userId);
    List<String> partecipants=event.getPartecipantList;
    partecipants.add(userId);
    eventCollection.get().then((value) => {
      for (var i = 0; i < value.size; i++) {
        if(value.docs[i].get('eventId') == event.eventId) {
          eventCollection.doc(value.docs[i].id).update({
            'partecipants' : partecipants,
            'applicants' : applicantsList,
            'firstFreeQrCode' : event.firstFreeQrCode++,
          })
        }
      }
    });
    log(event.firstFreeQrCode.toString());
    String userQrCode= event.getQrCodeList[event.firstFreeQrCode];
    await userQrCodesCollection.add({
      'user' : userId,
      'event' : event.getEventId,
      'qrCode' : userQrCode
      }
    );
  }

  void refuseApplicance(Event event, String userId) async{
    List<String> applicantsList=event.getApplicantList;
    applicantsList.remove(userId);
    eventCollection.get().then((value) => {
      for (var i = 0; i < value.size; i++) {
        if(value.docs[i].get('eventId') == event.eventId) {
          eventCollection.doc(value.docs[i].id).update({
            'applicants' : applicantsList,
          })
        }
      }
    });
  }

  Future<String> getQrCodeByUserEvent(Event event, String userId) async {
    String qrCode='';
    await userQrCodesCollection.get().then((value) => {
      for (var i = 0; i < value.size; i++) {
        if(value.docs[i].get('event')== event.getEventId && 
           value.docs[i].get('user')== userId){
             qrCode=value.docs[i].get('qrCode')
           }
      }
    });
    log(qrCode);
    return qrCode;

  }
}
