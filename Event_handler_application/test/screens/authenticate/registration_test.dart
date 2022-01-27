import 'package:event_handler/screens/authenticate/registration.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Check the presence of the desired widgets', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Registration(
        authServices: AuthService(MockFirebaseAuth()),
      ),
    ));
    final emailField = find.text('Enter your Email');
    final passwordField = find.text('Enter your Password');
    final nameField = find.text('Enter your Name');
    final surnameField = find.text('Enter your Surname');
    final ownerCheckBox = find.byType(Switch);
    final signUpButton = find.byType(ElevatedButton);

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(nameField, findsOneWidget);
    expect(surnameField, findsOneWidget);
    expect(ownerCheckBox, findsOneWidget);
    expect(signUpButton, findsOneWidget);
  });
}
