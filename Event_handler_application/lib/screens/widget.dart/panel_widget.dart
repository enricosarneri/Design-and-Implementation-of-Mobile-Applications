import 'package:event_handler/models/event.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelWidget extends StatelessWidget {
  const PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
    required this.event,
  }) : super(key: key);
  final ScrollController controller;
  final PanelController panelController;
  final Event event;
  
  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 12),
          buildDragHandle(),
          SizedBox(height: 36),
          buildAboutText(),
          SizedBox(height: 24),
          ElevatedButton(
              child: const Text('Ask to Partecipate'),
              onPressed: () async{
                final AuthService _authService = AuthService();
                DatabaseService(_authService.getCurrentUser()!.uid).addEventApplicant(event);
                //oppure mostrare un messagio con scritto Richiesta inviata con successo
                panelController.close();
              }),
        ],
      );

  Widget buildAboutText() => Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.name,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            Text(
              'description ' + event.description,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 24),
            Text(
              'max partecipants: ' + event.maxPartecipants.toString(),
              style: TextStyle(fontWeight: FontWeight.w400),
            ), 
          ],
        ),
      );

  Widget buildDragHandle() => GestureDetector(
        child: Center(
          child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        onTap: tooglePanel,
      );

  void tooglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();
}
