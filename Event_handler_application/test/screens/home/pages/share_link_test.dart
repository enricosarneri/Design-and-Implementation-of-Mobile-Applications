import 'package:event_handler/screens/home/pages/share_link.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  DatabaseService databaseService = DatabaseService('uid', firestore);
  testWidgets('share link ...', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Share_Link(databaseService: databaseService),
      ),
    );
    final eventLinkField = find.text('Event Link');
    final goToEventButton = find.text('Go to event');

    expect(eventLinkField, findsOneWidget);
    expect(goToEventButton, findsOneWidget);
  });
}
