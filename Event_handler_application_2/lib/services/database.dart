import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String uid;
  DatabaseService(this.uid);
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

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
}