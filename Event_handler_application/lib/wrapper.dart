import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/authenticate/sign_in.dart';
import 'package:event_handler/screens/authenticate/tutorial.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/services/database%20services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

//This class listen to the authentication changes, for instance log-in log-out
class Wrapper extends StatelessWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 500) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (width > 800) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    final AppUser? user = Provider.of<AppUser?>(context);
    if (user == null) {
      log("user is null");
      //  return SignIn(authServices: AuthService(FirebaseAuth.instance));
      return Tutorial(authServices: AuthService(FirebaseAuth.instance));
    } else {
      log("user not null");
      return Home();
    }
  }
}
