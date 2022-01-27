import 'package:event_handler/screens/locals/add_local.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Check the presence of the desired widgets', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AddLocal(
        authService: AuthService(MockFirebaseAuth()),
      ),
    ));
    final addresLocalField = find.text('Enter the Address of the Local...');
    final localNameField = find.text('Enter the Name of the Local...');
    final selectFileButton = find.text('Select File');
    final addLocalButton = find.byKey(Key('Add local button'));

    expect(addresLocalField, findsOneWidget);
    expect(localNameField, findsOneWidget);
    expect(selectFileButton, findsOneWidget);
    expect(addLocalButton, findsOneWidget);
  });
}
