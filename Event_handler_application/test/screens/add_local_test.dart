import 'package:event_handler/screens/add_local.dart';
import 'package:event_handler/services/auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('add local ...', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AddLocal(
        authService: AuthService(MockFirebaseAuth()),
      ),
    ));
    final addresLocalField = find.text('Address of your local');
    final localNameField = find.text('Local name');
    final selectFileButton = find.text('Select file');
    final addLocalButton = find.byKey(Key('add local button'));

    expect(addresLocalField, findsOneWidget);
    expect(localNameField, findsOneWidget);
    expect(selectFileButton, findsOneWidget);
    expect(addLocalButton, findsOneWidget);
  });
}
