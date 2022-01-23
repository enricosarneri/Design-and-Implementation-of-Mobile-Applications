import 'package:event_handler/models/event.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQr extends StatelessWidget {
  @override
  const ShowQr({
    Key? key,
    required this.event,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);
  final Event event;
  final AuthService authService;
  final DatabaseService databaseService;

  @override
  Widget build(BuildContext context) {
    final String userId = authService.getCurrentUser()!.uid;
    return Scaffold(
      body: Container(
        color: Color(0xFF121B22),
        child: Center(
          child: FutureBuilder(
            future: databaseService.getQrCodeByUserEvent(event, userId),
            initialData: "Loading text..",
            builder: (BuildContext context, AsyncSnapshot<String> text) {
              return QrImage(
                key: Key('qrCode'),
                data: text.data!,
                size: 300,
                backgroundColor: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}
