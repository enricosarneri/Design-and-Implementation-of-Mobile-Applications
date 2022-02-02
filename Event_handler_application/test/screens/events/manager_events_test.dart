import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/screens/events/manager_events.dart';
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
  List<String> partecipants = [];

  CollectionReference addEventToCollection(String uid, String name) {
    CollectionReference event = fakeFirebaseFirestore2.collection('myEvents');
    String eventCollection = 'myEvents';
    fakeFirebaseFirestore2.collection(eventCollection).add({
      'manager': uid,
      'name': name,
      'urlImage': 'urlImage',
      'description': 'description',
      'latitude': 0,
      'longitude': 0,
      'placeName': 'typeOfPlace',
      'eventType': 'eventType',
      'dateBegin': '25/12/2022',
      'dateEnd': '26/12/2022',
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

  testWidgets('Manager owns no event', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ManagerEvents(
        databaseService: mockDatabaseService,
        authService: mockAuthService,
      ),
    ));
    mockDatabaseService.addEventToCollection('uid', 'eventName');
    await tester.pump();
    final eventName = find.text('eventName');
    expect(eventName, findsNothing);
  });

/*
  testWidgets('Manager owns exactly 1 event', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: ManagerEvents(
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ));
      await tester.pump(Duration(seconds: 2));
      mockDatabaseService.addEventToCollection('myUid', 'eventName');
      mockDatabaseService.addEventToCollection('uid123', 'eventName1');
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();
      final eventName = find.text('eventName');
      final event2Name = find.text('eventName1');
      expect(event2Name, findsNothing);
      expect(eventName, findsOneWidget);
    });
  });

  final MockDatabaseService mockDatabaseService2 = MockDatabaseService();

  testWidgets('Manager owns more than 1 event', (tester) async {
    mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        home: ManagerEvents(
          databaseService: mockDatabaseService2,
          authService: mockAuthService,
        ),
      ));
      mockDatabaseService2.addEventToCollection('myUid', 'eventName');
      mockDatabaseService2.addEventToCollection('myUid', 'eventName2');
      mockDatabaseService2.addEventToCollection('myUid', 'eventName3');
      mockDatabaseService2.addEventToCollection('uid123', 'eventName4');
      await tester.pump();
      final eventName = find.text('eventName');
      final event2Name = find.text('eventName2');
      final event3Name = find.text('eventName3');
      final event4Name = find.text('eventName4');
      expect(eventName, findsOneWidget);
      expect(event2Name, findsOneWidget);
      expect(event3Name, findsOneWidget);
      expect(event4Name, findsNothing);
    });
  });
  */
}
