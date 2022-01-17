import 'package:event_handler/screens/authenticate/sign_in.dart';
import 'package:event_handler/services/auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign in ...', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignIn(
        authServices: AuthService(MockFirebaseAuth()),
      ),
    ));
    final emailField = find.text('Enter your Email');
    final passwordField = find.text('Enter your Password');
    final signInButton = find.byType(ElevatedButton);

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(signInButton, findsOneWidget);
  });
}
