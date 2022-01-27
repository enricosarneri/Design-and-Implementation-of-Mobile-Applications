import 'package:event_handler/models/event.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/services/database%20services/database.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          '',
        ),
        backgroundColor: Color(0xFF121B22),
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFF121B22),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: "hero1",
                child: Container(
                  height: 300,
                  width: 300,
                  child: FutureBuilder(
                    future: databaseService.getQrCodeByUserEvent(event, userId),
                    initialData: "Loading text..",
                    builder:
                        (BuildContext context, AsyncSnapshot<String> text) {
                      return Center(
                        child: QrImage(
                          key: Key('qrCode'),
                          data: text.data!,
                          size: 270,
                          backgroundColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
