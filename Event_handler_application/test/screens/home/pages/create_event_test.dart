import 'dart:async';

import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/home/pages/create_event.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  List<Local> locals = [];

  void addLocal(Local local) {
    locals.add(local);
  }

  @override
  Future<List<Local>> getMyLocals() {
    var localcompl = Completer<List<Local>>();
    localcompl.complete(locals);
    return localcompl.future;
  }
}

void main() {
  final firestore = FakeFirebaseFirestore();
  MockDatabaseService mockDatabaseService = MockDatabaseService();
  DatabaseService databaseService = DatabaseService('uid', firestore);

  testWidgets('Check the presence of the desired widgets', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Create_Event(
        databaseService: databaseService,
      ),
    ));

    final nameField = find.text('Name of the Event');
    final placeNameField = find.text('Place of the Event');
    final descriptionField = find.text('Description of the Event');
    final maxPartecipantsField = find.text('Maximum of Partecipants');
    final priceField = find.text('Price');
    final eventTypeField = find.text('Type of Place');
    final placeTypeField = find.text('Place of the Event');
    final dataButton = find.text('Start Date-Time');
    final createEventButton = find.text('Create Event');

    expect(nameField, findsOneWidget);
    expect(descriptionField, findsOneWidget);
    expect(placeTypeField, findsOneWidget);
    expect(placeNameField, findsOneWidget);
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();
    expect(priceField, findsOneWidget);
    expect(eventTypeField, findsOneWidget);
    expect(dataButton, findsOneWidget);
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();
    expect(maxPartecipantsField, findsOneWidget);
    expect(createEventButton, findsOneWidget);
  });

/*
  testWidgets('Check the presence of the correct local type', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Create_Event(
        databaseService: databaseService,
      ),
    ));

    final placeTypeField = find.byKey(Key('Type of Place'));
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -100));
    await tester.pump();
    await tester.tap(placeTypeField);
    await tester.pumpAndSettle();

    final dropdownItem = find.text('Cinema').last;
    final dropdownItem2 = find.text('Theatre').last;
    final dropdownItem3 = find.text('Restaurant').last;
    final dropdownItem4 = find.text('Bar/Pub').last;
    final dropdownItem5 = find.text('Disco').last;
    final dropdownItem6 = find.text('Private Setting').last;
    expect(dropdownItem, findsOneWidget);
    expect(dropdownItem2, findsOneWidget);
    expect(dropdownItem3, findsOneWidget);
    expect(dropdownItem4, findsOneWidget);
    expect(dropdownItem5, findsOneWidget);
    expect(dropdownItem6, findsOneWidget);
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();
    expect(dropdownItem, findsOneWidget);
  });

  testWidgets('Check the presence of the correct event type', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Create_Event(
        databaseService: databaseService,
      ),
    ));

    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();
    final eventTypeField = find.byKey(Key('Privacy of the Event'));
    await tester.tap(eventTypeField);
    await tester.pumpAndSettle();
    final dropdownItem = find.text('Public').last;
    final dropdownItem2 = find.text('Private').last;
    expect(dropdownItem, findsOneWidget);
    expect(dropdownItem2, findsOneWidget);

    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    expect(dropdownItem, findsOneWidget);
  });

  testWidgets('Check the presence of the correct locals in the local field',
      (tester) async {
    mockDatabaseService
        .addLocal(Local('owner', 'localName', 'localAddress', 0, 0));
    mockDatabaseService
        .addLocal(Local('owner', 'localName2', 'localAddress', 0, 0));
    await tester.pumpWidget(MaterialApp(
      home: Create_Event(
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.pumpAndSettle(Duration(seconds: 1));

    final placeNameField = find.byKey(Key('Place of the Event'));
    await tester.tap(placeNameField);
    await tester.pumpAndSettle();

    final dropdownItem = find.text('localName').last;
    final dropdownItem2 = find.text('localName').last;

    expect(dropdownItem, findsOneWidget);
    expect(dropdownItem2, findsOneWidget);

    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    expect(dropdownItem, findsOneWidget);
  });
*/
}
