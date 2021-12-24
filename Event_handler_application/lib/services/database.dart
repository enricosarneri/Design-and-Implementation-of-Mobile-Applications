import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String uid;
  DatabaseService(this.uid);
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference eventCollection = FirebaseFirestore.instance.collection('events');


  Future createUserData (String email, String password, String name, String surname, bool isOwner) async{
    return await userCollection.doc(uid).set({
      'email' : email,
      'password' : password,
      'name' : name,
      'surname' : surname,
      'isowner' : isOwner,
      }  
    );
  }

    Future createEventData (String name, String description, String? eventType, DateTime? date, int maxPartecipants) async{
    return await eventCollection.doc(uid).set({
      'name' : name,
      'description' : description,
      'eventType' : eventType,
      'date' : date.toString(),
      'maxPartecipants' : maxPartecipants,
      }  
    );
  }
}