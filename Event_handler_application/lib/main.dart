import 'package:event_handler/models/user.dart';
import 'package:event_handler/services/localization%20services/application_block.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  void checkPermission() async {
    if (await Permission.location.request().isDenied &&
        await Permission.storage.request().isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    checkPermission();
    return StreamProvider<AppUser?>.value(
      value: AuthService(FirebaseAuth.instance).user,
      initialData: null,
      child: ChangeNotifierProvider(
        create: (context) => ApplicationBlock(),
        child: const MaterialApp(
          home: Wrapper(),
        ),
      ),
    );
  }
}
