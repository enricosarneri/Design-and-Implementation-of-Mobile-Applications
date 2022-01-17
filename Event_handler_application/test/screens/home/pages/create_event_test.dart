import 'dart:async';

import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/home/pages/create_event.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  DatabaseService databaseService = DatabaseService('uid', firestore);
  List<Local> locals = [];
  var localcompl = Completer<List<Local>>();
  localcompl.complete(locals);

  testWidgets('create event ...', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Create_Event(
        databaseService: databaseService,
      ),
    ));

    final nameField = find.byKey(Key('name'));
    final placNnameField = find.byKey(Key('place name'));
    final descriptionField = find.byKey(Key('description'));
  });
}
