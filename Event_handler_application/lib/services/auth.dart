import 'dart:developer';

import 'package:event_handler/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

  final FirebaseAuth _auth=FirebaseAuth.instance;
  //create user obj based on FirebaseUser
  AppUser? _userFromFirebaseUser(User? user){
    return user!=null ? AppUser(user.uid,user.email,user.displayName) : null;
  }

  Future signInWithEmailAndPassword (String email, String password) async {
    try{
    UserCredential userCredential= await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? user= userCredential.user;
    return _userFromFirebaseUser(user);
    } catch(e){
      log(e.toString());
      return null;
    }
  }

    Future createUserWithEmailAndPassword (String email, String password) async {
    try{
    UserCredential userCredential= await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user= userCredential.user;
    return user;
    } catch(e){
      log(e.toString());
      return null;
    }
  }

    Future signOut() async{
      try{
        return await _auth.signOut();
      }catch(e){
        log(e.toString());
        return null;
      }
    }



  Stream<AppUser?> get user{
    log((_auth.authStateChanges().map((User? user) => _userFromFirebaseUser(user))).toString());
    return _auth.authStateChanges().map((User? user) => _userFromFirebaseUser(user!));
  }

}