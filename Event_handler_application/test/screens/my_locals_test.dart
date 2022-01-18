import 'dart:async';

import 'package:event_handler/models/local.dart';
import 'package:event_handler/screens/my_locals.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  List<Local> locals = [];
  void addToLocal(newLocal) {
    locals.add(newLocal);
  }

  @override
  Future<List<Local>> getMyLocals() {
    var localcompl = Completer<List<Local>>();
    localcompl.complete(locals);
    return localcompl.future;
  }
}

void main() {
  final MockDatabaseService mockDatabaseService = MockDatabaseService();

  testWidgets('Find no addresses', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyLocals(
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 2));
    final address = find.text('localAddress');
    expect(address, findsNothing);
  });

  testWidgets('Check the presence of a single address', (tester) async {
    mockDatabaseService
        .addToLocal(Local('owner', 'localName', 'localAddress', 0, 0));

    await tester.pumpWidget(MaterialApp(
      home: MyLocals(
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 2));
    final address = find.text('localAddress');
    expect(address, findsOneWidget);
  });

  testWidgets('Check the prensence of more than 1 address', (tester) async {
    mockDatabaseService
        .addToLocal(Local('owner', 'localName', 'localAddress2', 0, 0));
    mockDatabaseService
        .addToLocal(Local('owner', 'localName', 'localAddress3', 0, 0));

    await tester.pumpWidget(MaterialApp(
      home: MyLocals(
        databaseService: mockDatabaseService,
      ),
    ));
    await tester.pump(Duration(seconds: 2));
    final address = find.text('localAddress');
    final addres2 = find.text('localAddress2');
    final addres3 = find.text('localAddress3');
    expect(address, findsOneWidget);
    expect(addres2, findsOneWidget);
    expect(addres3, findsOneWidget);
  });
}
