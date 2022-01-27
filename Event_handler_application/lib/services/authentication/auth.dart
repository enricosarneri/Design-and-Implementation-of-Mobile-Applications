import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/services/database%20services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  String errorMessage = '';
  AppUser? appUser;
  //create user obj based on FirebaseUser
  AppUser? _userFromFirebaseUser(User? user) {
    return user != null ? AppUser(user.uid, user.email!) : null;
  }

  AuthService(this._auth);

  Future signInWithEmailAndPassword(String email, String password) async {
    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message!;
      Fluttertoast.showToast(msg: errorMessage);
      return null;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future createUserWithEmailAndPassword(String email, String password,
      String name, String surname, bool isOwner) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user == null)
        return null;
      else {
        await DatabaseService(user.uid, FirebaseFirestore.instance)
            .updateUserData(email, password, name, surname, isOwner);
        return user;
      }
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message!;
      Fluttertoast.showToast(msg: errorMessage);
      return null;
    }
  }

  Future<String> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Email sent";
    } catch (e) {
      return "Error occurred";
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<AppUser?> get user {
    log((_auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user))).toString());
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }
}
