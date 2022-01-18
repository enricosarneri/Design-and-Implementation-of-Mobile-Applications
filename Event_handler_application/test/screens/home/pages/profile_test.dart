import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/home/pages/profile.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../events/manager_events_test.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  AppUser appUser =
      AppUser.fromAppUser('uid', 'email', 'name', 'surname', 'password', true);

  void setAppUser(AppUser appUser) {
    this.appUser = appUser;
  }

  @override
  Future<AppUser> getCurrentAppUser() {
    var futureAppUser = Completer<AppUser>();
    futureAppUser.complete(appUser);
    return futureAppUser.future;
  }
}

void main() {
  final MockDatabaseService mockDatabaseService = MockDatabaseService();
  final MockAuthService mockAuthService = MockAuthService();
  testWidgets('Check the presence of every widget if the person is an owner',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Profile(
        databaseService: mockDatabaseService,
        authService: mockAuthService,
      ),
    ));
    await tester.pump(Duration(seconds: 2));
    final logoutButton = find.text('log out');
    final organizedEventButton = find.text('Organized events');
    final myEventsButton = find.text('My events');
    final myLocalsButton = find.text('My Locals');

    expect(logoutButton, findsOneWidget);
    expect(myEventsButton, findsOneWidget);
    expect(organizedEventButton, findsOneWidget);
    expect(myLocalsButton, findsOneWidget);
  });

  testWidgets(
      'Check the presence of every widget if the person is not an owner',
      (tester) async {
    mockDatabaseService.setAppUser(AppUser.fromAppUser(
        'uid', 'email', 'name', 'surname', 'password', false));
    await tester.pumpWidget(MaterialApp(
      home: Profile(
        databaseService: mockDatabaseService,
        authService: mockAuthService,
      ),
    ));
    await tester.pump(Duration(seconds: 2));

    final logoutButton = find.text('log out');
    final organizedEventButton = find.text('Organized events');
    final myEventsButton = find.text('My events');
    final myLocalsButton = find.text('My Locals');

    expect(logoutButton, findsOneWidget);
    expect(organizedEventButton, findsNothing);
    expect(myEventsButton, findsOneWidget);
    expect(myLocalsButton, findsNothing);
  });
}
