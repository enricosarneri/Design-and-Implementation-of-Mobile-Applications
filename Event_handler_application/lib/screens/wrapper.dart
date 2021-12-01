import 'dart:developer';

import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/authenticate/authenticate.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//This class listen to the authentication changes, for instance log-in log-out
class Wrapper extends StatelessWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppUser? user = Provider.of<AppUser?> (context);
    if(user == null ){
      log("user is null");
      return Authenticate();
    }
    else{
      log(user.toString());
      return Home();
    }
  } 
} 