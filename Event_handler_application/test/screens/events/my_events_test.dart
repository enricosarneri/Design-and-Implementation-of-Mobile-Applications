import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Stream<QuerySnapshot> getEvents() {
    // TODO: implement getEvents
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('my events ...', (tester) async {
    // TODO: Implement test
  });
}
