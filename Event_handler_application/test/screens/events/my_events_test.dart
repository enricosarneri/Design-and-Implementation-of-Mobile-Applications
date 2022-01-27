import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/events/my_events.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:event_handler/services/database%20services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  FakeFirebaseFirestore fakeFirebaseFirestore2 = FakeFirebaseFirestore();
  List<String> applicants = [];
  List<String> qrCodes = [];

  CollectionReference addEventToCollection(String uid, String name,
      String description, List<String> partecipants, String date) {
    CollectionReference event = fakeFirebaseFirestore2.collection('myEvents');
    String eventCollection = 'myEvents';
    fakeFirebaseFirestore2.collection(eventCollection).add({
      'manager': uid,
      'name': name,
      'urlImage': 'urlImage',
      'description': description,
      'latitude': 0,
      'longitude': 0,
      'placeName': 'typeOfPlace',
      'eventType': 'eventType',
      'date': date,
      'maxPartecipants': 6,
      'price': 5,
      'qrCodeList': qrCodes,
      'partecipants': partecipants,
      'applicants': applicants,
      'eventId': 'eventId',
      'firstFreeQrCode': 0,
    });
    return event;
  }

  @override
  Stream<QuerySnapshot> getEvents() {
    CollectionReference events = fakeFirebaseFirestore2.collection('myEvents');
    return events.snapshots();
  }
}

class MockAuthService extends Mock implements AuthService {
  @override
  User? getCurrentUser() {
    return MockUser(
        isAnonymous: false,
        uid: 'myUid',
        email: "somemail@email.com",
        displayName: 'bob');
  }
}

void main() {
  final MockDatabaseService mockDatabaseService = MockDatabaseService();
  final MockAuthService mockAuthService = MockAuthService();

  testWidgets('0 events when i dont partecipate to any', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyEvents(
        databaseService: mockDatabaseService,
        authService: mockAuthService,
      ),
    ));
    List<String> partecipants = [];
    partecipants.add('not myUid');
    mockDatabaseService.addEventToCollection(
        'uid', 'eventName', 'description', partecipants, '12/12/2022');
    await tester.pump();
    final eventName = find.text('eventName');
    expect(eventName, findsNothing);
  });

  testWidgets('Exactly 1 event when i partecipate to 1 event', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: MyEvents(
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ));
      List<String> partecipants = [];
      partecipants.add('myUid');
      partecipants.add('Uid2');
      partecipants.add('uid3');
      mockDatabaseService.addEventToCollection(
          'uid', 'eventName', 'description', partecipants, '12/12/2022');
      await tester.pump();
      final eventName = find.text('eventName');
      expect(eventName, findsOneWidget);
    });
  });

  final MockDatabaseService mockDatabaseService2 = MockDatabaseService();

  testWidgets('More than 1 event when i partecipate to more than 1 event',
      (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: MyEvents(
          databaseService: mockDatabaseService2,
          authService: mockAuthService,
        ),
      ));
      List<String> partecipants = [];
      partecipants.add('myUid');
      mockDatabaseService2.addEventToCollection(
          'uid', 'eventName', 'description', partecipants, '12/12/2022');
      mockDatabaseService2.addEventToCollection(
          'uid', 'eventName2', 'description', partecipants, '12/12/2022');
      mockDatabaseService2.addEventToCollection(
          'uid', 'eventName3', 'description', partecipants, '12/12/2022');
      await tester.pump();
      final eventName = find.text('eventName');
      final event2Name = find.text('eventName2');
      final event3Name = find.text('eventName3');
      expect(eventName, findsOneWidget);
      expect(event2Name, findsOneWidget);
      expect(event3Name, findsOneWidget);
    });
  });
}
