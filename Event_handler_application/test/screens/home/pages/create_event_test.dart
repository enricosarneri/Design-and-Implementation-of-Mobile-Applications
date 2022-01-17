import 'dart:async';

import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/home/pages/create_event.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  DatabaseService databaseService = DatabaseService('uid', firestore);
  List<Local> locals = [];
  var localcompl = Completer<List<Local>>();
  localcompl.complete(locals);

  testWidgets('Check the presence of the desired widgets', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Create_Event(
        databaseService: databaseService,
      ),
    ));

    final nameField = find.byKey(Key('name'));
    final placeNameField = find.byKey(Key('place name'));
    final descriptionField = find.byKey(Key('description'));
    final maxPartecipantsField = find.byKey(Key('max partecipants'));
    final priceField = find.byKey(Key('price'));
    final eventTypeField = find.byKey(Key('event type'));
    final placeTypeField = find.byKey(Key('place type'));
    final dataButton = find.byKey(Key('data button'));
    final createEventButton = find.byKey(Key('create event button'));
    final uploadImageButton = find.byKey(Key('upload image button'));

    expect(nameField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(placeTypeField, findsOneWidget);
    expect(uploadImageButton, findsOneWidget);
    expect(placeNameField, findsOneWidget);
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();
    expect(priceField, findsOneWidget);
    expect(eventTypeField, findsOneWidget);
    expect(dataButton, findsOneWidget);
    expect(maxPartecipantsField, findsOneWidget);
    expect(createEventButton, findsOneWidget);
  });
}
