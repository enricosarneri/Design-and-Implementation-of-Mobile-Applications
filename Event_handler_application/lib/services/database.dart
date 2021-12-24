import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/screens/home/location_services.dart';
import 'package:geocoder/geocoder.dart';

class DatabaseService{
  final String uid;
  DatabaseService(this.uid);
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference eventCollection = FirebaseFirestore.instance.collection('events');


  Future updateUserData (String email, String password, String name, String surname, bool isOwner) async{
    return await userCollection.doc(uid).set({
      'email' : email,
      'password' : password,
      'name' : name,
      'surname' : surname,
      'isowner' : isOwner,
      }  
    );
  }


  Stream<QuerySnapshot> get events{
    return eventCollection.snapshots();
  }


    Future createEventData (String name, String description, String address,String? eventType, DateTime? date, String maxPartecipants) async{
      Coordinates coordinates= await LocationService().getCoordinatesByAddress(address);
    return await eventCollection.add({
      'manager' : uid,
      'name' : name,
      'description' : description,
      'coordinates' : coordinates.toString(),
      'eventType' : eventType,
      'date' : date.toString(),
      'maxPartecipants' : maxPartecipants,
      }  
    );
  }
}