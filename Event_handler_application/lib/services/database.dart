import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/screens/home/services/location_services.dart';
import 'package:event_handler/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';

class DatabaseService {
  final String uid;
  DatabaseService(this.uid);
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection('events');

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

  Stream<QuerySnapshot> getEvents(){
    return eventCollection.snapshots();
  }

  List<Event> eventListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((e){
      return Event(e.get('manager'), e.get('name'), e.get('description'), double.parse(e.get('latitude')), double.parse(e.get('longitude')), e.get('placeName'), e.get('eventType'),
        e.get('date'), int.parse(e.get('maxPartecipants')));
    }).toList();
  }

  Stream<List<Event>> get events{
    return eventCollection.snapshots().map(eventListFromSnapshot);
  }

    Future createEventData (String name, String description, String address,String placeName,String? eventType, DateTime? date, String maxPartecipants) async{
      Coordinates coordinates= await LocationService().getCoordinatesByAddress(address);
    return await eventCollection.add({
      'manager' : uid,
      'name' : name,
      'description' : description,
      'latitude' : coordinates.latitude.toString(),
      'longitude' : coordinates.longitude.toString(),
      'placeName' : placeName,
      'eventType' : eventType,
      'date' : date.toString(),
      'maxPartecipants' : maxPartecipants,
      }  
    );
  }
}
