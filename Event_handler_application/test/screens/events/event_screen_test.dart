import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/event_screen.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  User? getCurrentUser() {
    return MockUser(
        isAnonymous: false,
        uid: 'managerId',
        email: "somemail@email.com",
        displayName: 'bob');
  }
}

class MockDatabaseService extends Mock implements DatabaseService {
  FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();

  CollectionReference addUserToCollection(
    String name,
    String surname,
    String email,
    String uid,
  ) {
    CollectionReference user = fakeFirebaseFirestore.collection('users');
    String userCollection = 'users';
    fakeFirebaseFirestore.collection(userCollection).doc(uid).set({
      'email': email,
      'password': 'password',
      'name': name,
      'surname': surname,
      'isowner': false,
    });
    return user;
  }

  @override
  Stream<QuerySnapshot> getUsers() {
    CollectionReference users = fakeFirebaseFirestore.collection('users');
    return users.snapshots();
  }

  @override
  Stream<QuerySnapshot> getEvents() {
    CollectionReference events = fakeFirebaseFirestore.collection('events');
    return events.snapshots();
  }
}

void main() {
  final MockAuthService mockAuthService = MockAuthService();
  final MockDatabaseService mockDatabaseService = MockDatabaseService();

  List<String> partecipants = [];
  List<String> applicants = [];
  List<String> qrCodes = [];
  int maxPartecipants = 10;

  testWidgets('Check the presence of the correct widgets for a partecipant',
      (tester) async {
    await tester.pump(Duration(seconds: 3));
    await tester.pumpWidget(MaterialApp(
      home: EventScreen(
        event: Event(
            'any managerID',
            'name',
            'urlImage',
            'description',
            0,
            0,
            'placeName',
            'typeOfPlace',
            'eventType',
            'date',
            maxPartecipants,
            5,
            'eventId',
            partecipants,
            applicants,
            qrCodes,
            0),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 3));
    final eventName = find.text('name');
    final peopleAskinTojoin =
        find.text('People asking to join: ' + applicants.length.toString());
    final maxPartecipantText = find.text('Partecipants: ' +
        partecipants.length.toString() +
        '/' +
        maxPartecipants.toString());
    final scanQrButton = find.text('Scan Qr');
    final qrCode = find.text('qrCode');
    final shareButton = find.text('share button');
    //await tester.drag(
    // find.byKey(Key('scrollable column')), const Offset(0.0, -200));
    await tester.pump();

    expect(maxPartecipantText, findsOneWidget);
    expect(eventName, findsOneWidget);
    expect(scanQrButton, findsNothing);
    //expect(peopleAskinTojoin, findsNothing);
    //expect(partecipantsLengthText, findsNothing);
    //expect(shareButton, findsOneWidget);
    //expect(qrCode, findsOneWidget);
  });

  testWidgets(
      'Check the presence of the correct widgets for the manager of the event',
      (tester) async {
    await tester.pump(Duration(seconds: 3));
    await tester.pumpWidget(MaterialApp(
      home: EventScreen(
        event: Event(
            'managerId',
            'name',
            'urlImage',
            'description',
            0,
            0,
            'placeName',
            'typeOfPlace',
            'eventType',
            'date',
            10,
            5,
            'eventId',
            partecipants,
            applicants,
            qrCodes,
            0),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 3));
    final maxPartecipantText = find.text('Partecipants: ' +
        partecipants.length.toString() +
        '/' +
        maxPartecipants.toString());
    final eventName = find.text('name');
    final peopleAskinTojoin =
        find.text('People asking to join: ' + applicants.length.toString());
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();

    final scanQrButton = find.text('Scan Qr Code');
    final qrCode = find.text('qrCode');
    final shareButton = find.text('share button');
    expect(maxPartecipantText, findsOneWidget);
    expect(eventName, findsOneWidget);
    expect(peopleAskinTojoin, findsOneWidget);
    expect(scanQrButton, findsOneWidget);
    expect(qrCode, findsNothing);
    expect(shareButton, findsNothing);
  });

  testWidgets('Check the presence of the applicants from applicants list',
      (tester) async {
    applicants.add('luca');
    applicants.add('Marco');
    applicants.add('Giovanni');
    mockDatabaseService.addUserToCollection(
        'luca', 'cognome', 'email1', 'luca');
    mockDatabaseService.addUserToCollection(
        'Marco', 'cognome', 'email2', 'Marco');
    mockDatabaseService.addUserToCollection(
        'Giovanni', 'cognome', 'email3', 'Giovanni');
    await tester.pump(Duration(seconds: 3));
    await tester.pumpWidget(MaterialApp(
      home: EventScreen(
        event: Event(
            'managerId',
            'name',
            'urlImage',
            'description',
            0,
            0,
            'placeName',
            'typeOfPlace',
            'eventType',
            'date',
            10,
            5,
            'eventId',
            partecipants,
            applicants,
            qrCodes,
            0),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 3));
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -500));
    await tester.pump();

    final name1 = find.text('luca cognome ');
    final name2 = find.text('Marco cognome ');
    final name3 = find.text('Giovanni cognome ');
    final email1 = find.text('email1');
    final email2 = find.text('email2');
    final email3 = find.text('email3');

    expect(name1, findsOneWidget);
    expect(email1, findsOneWidget);

    await tester.drag(
        find.byKey(Key('applicant List scroll')), const Offset(0.0, -100));
    await tester.pump();
    expect(name2, findsOneWidget);
    expect(email2, findsOneWidget);

    await tester.drag(
        find.byKey(Key('applicant List scroll')), const Offset(0.0, -100));
    await tester.pump();
    expect(name3, findsOneWidget);
    expect(email3, findsOneWidget);
  });

  testWidgets('Check the presence of the partecipants from partecipant list',
      (tester) async {
    partecipants.clear();
    applicants.clear();
    partecipants.add('luca');
    partecipants.add('Marco');
    partecipants.add('Giovanni');
    mockDatabaseService.addUserToCollection(
        'luca', 'cognome', 'email1', 'luca');
    mockDatabaseService.addUserToCollection(
        'Marco', 'cognome', 'email2', 'Marco');
    mockDatabaseService.addUserToCollection(
        'Giovanni', 'cognome', 'email3', 'Giovanni');
    await tester.pump(Duration(seconds: 3));
    await tester.pumpWidget(MaterialApp(
      home: EventScreen(
        event: Event(
            'managerId',
            'name',
            'urlImage',
            'description',
            0,
            0,
            'placeName',
            'typeOfPlace',
            'eventType',
            'date',
            10,
            5,
            'eventId',
            partecipants,
            applicants,
            qrCodes,
            0),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 3));

    final name1 = find.text('luca cognome ');
    final name2 = find.text('Marco cognome ');
    final name3 = find.text('Giovanni cognome ');
    final email1 = find.text('email1');
    final email2 = find.text('email2');
    final email3 = find.text('email3');

    expect(name1, findsOneWidget);
    expect(email1, findsOneWidget);
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -100));
    await tester.pump();

    expect(name2, findsOneWidget);
    expect(email2, findsOneWidget);
    await tester.drag(find.byKey(Key('list view')), const Offset(0.0, -100));
    await tester.pump();
    expect(name3, findsOneWidget);
    expect(email3, findsOneWidget);
  });
}
