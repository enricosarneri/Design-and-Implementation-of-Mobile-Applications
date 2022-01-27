import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/services/database.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  FakeFirebaseFirestore fakeFirebaseFirestore = FakeFirebaseFirestore();
  DatabaseService databaseService =
      DatabaseService('my userID', fakeFirebaseFirestore);
  List<String> partecipants = [];
  List<String> applicants = [];
  List<String> qrCodes = [];
  Event event = Event(
      "managerId",
      "name",
      "urlImage",
      "description",
      2.3,
      2.3,
      "placeName",
      "typeOfPlace",
      "eventType",
      "12/12/2021",
      "12/12/2023",
      55,
      5,
      "eventId",
      partecipants,
      applicants,
      qrCodes,
      0);

  tearDown(() {
    //used to clear the collection on the fakeFirebaseFirestore
    qrCodes.clear();
    partecipants.clear();
    applicants.clear();
    fakeFirebaseFirestore.collection("events").get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
    fakeFirebaseFirestore.collection("userQrCodes").get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
    fakeFirebaseFirestore.collection("users").get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });

    fakeFirebaseFirestore.collection("ownerLocals").get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
  });

  testWidgets(
      'Checks if addEventApplicant add the current user to the applicanceList',
      (tester) async {
    databaseService.addEventApplicant(event);
    fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
    });
    //get the list of the applicantList from the fakeFirestore
    List<String> firebaseApplicantsList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebaseApplicantsList =
                      List<String>.from(value.docs[i].get('applicants'))
                }
            }
        });

    expect(applicants[0], 'my userID');
    expect(firebaseApplicantsList[0], 'my userID');
    expect(applicants.length, 1);
    expect(firebaseApplicantsList.length, 1);
  });

  testWidgets(
      'Checks if addEventApplicant does not add a duplicate if im already in the applicance List',
      (tester) async {
    databaseService.addEventApplicant(event);
    fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
    });

    //get the list of the applicantList from the fakeFirestore
    List<String> firebaseApplicantsList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebaseApplicantsList =
                      List<String>.from(value.docs[i].get('applicants'))
                }
            }
        });

    expect(applicants[0], 'my userID');
    expect(firebaseApplicantsList[0], 'my userID');
    expect(applicants.length, 1);
    expect(firebaseApplicantsList.length, 1);
  });

  testWidgets(
      'Checks if addEventApplicant does not add the manager of the event in the applicance List',
      (tester) async {
    Event event2 = Event(
        "my userID",
        "name",
        "urlImage",
        "description",
        2.3,
        2.3,
        "placeName",
        "typeOfPlace",
        "eventType",
        "12/12/2021",
        "12/12/2023",
        55,
        5,
        "eventId",
        partecipants,
        applicants,
        qrCodes,
        0);
    databaseService.addEventApplicant(event2);
    fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
    });

    //get the list of the applicantList from the fakeFirestore
    List<String> firebaseApplicantsList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebaseApplicantsList =
                      List<String>.from(value.docs[i].get('applicants'))
                }
            }
        });
    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });

    expect(applicants.length, 0);
    expect(firebaseApplicantsList.length, 0);
    expect(firebasePartecipantList.length, 0);
  });

  testWidgets(
      'Checks if addEventApplicant does not add a user already in the partecipantList',
      (tester) async {
    partecipants.add('my userID');
    Event event2 = Event(
        "managerID",
        "name",
        "urlImage",
        "description",
        2.3,
        2.3,
        "placeName",
        "typeOfPlace",
        "eventType",
        "12/12/2021",
        "12/12/2023",
        55,
        5,
        "eventId",
        partecipants,
        applicants,
        qrCodes,
        0);
    databaseService.addEventApplicant(event2);
    fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
    });

    //get the list of the applicantList from the fakeFirestore
    List<String> firebaseApplicantsList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebaseApplicantsList =
                      List<String>.from(value.docs[i].get('applicants'))
                }
            }
        });
    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });

    expect(applicants.length, 0);
    expect(firebaseApplicantsList.length, 0);
    expect(firebasePartecipantList.length, 1);
    expect(firebasePartecipantList[0], "my userID");
  });
  testWidgets(
      'Checks if the Accept Applicance is accepting an user in the applicanceList when he s the only one applying',
      (tester) async {
    applicants.add('my userID');
    qrCodes.add("asddsa");
    qrCodes.add("4112");
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "notme",
      'firstFreeQrCode': 0,
    });
    databaseService.acceptApplicance(event, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });

    expect(applicants.length, 0);
    expect(firebasePartecipantList.length, 1);
    expect(firebasePartecipantList[0], 'my userID');
  });

  testWidgets(
      'Checks if the Accept Applicance is accepting an user in the applicanceList when more than 1 person is applying',
      (tester) async {
    applicants.add('id1');
    applicants.add('my userID');
    applicants.add('id2');
    qrCodes.add("asddsa");
    qrCodes.add("4112");

    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "notme",
      'firstFreeQrCode': 0,
    });
    databaseService.acceptApplicance(event, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });

    expect(applicants.length, 2);
    expect(firebasePartecipantList.length, 1);
    expect(firebasePartecipantList[0], 'my userID');
  });

  testWidgets(
      'Checks if the Accept Applicance is refusing the owner of the event',
      (tester) async {
    applicants.add('my userID');
    qrCodes.add("asddsa");
    qrCodes.add("4112");
    qrCodes.add("4132");
    qrCodes.add("416423");
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "my userID",
      'firstFreeQrCode': 0,
    });
    databaseService.acceptApplicance(event, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });

    expect(applicants.length, 0);
    expect(firebasePartecipantList.length, 0);
  });

  testWidgets(
      'Checks if the Accept Applicance is refusing a person already partecipating the event',
      (tester) async {
    applicants.add('my userID');
    partecipants.add('my userID');
    qrCodes.add("asddsa");
    qrCodes.add("4112");
    qrCodes.add("4132");
    qrCodes.add("416423");
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "my userID",
      'firstFreeQrCode': 0,
    });
    databaseService.acceptApplicance(event, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });

    expect(applicants.length, 0);
    expect(firebasePartecipantList.length, 1);
    expect(firebasePartecipantList[0], "my userID");
  });

  testWidgets(
      'Checks after accepting an user that is receveing the correct qrCode with the firstFreeQrCode set to 0',
      (tester) async {
    Event event2 = Event(
        "managerId",
        "name",
        "urlImage",
        "description",
        0,
        0,
        "placeName",
        "typeOfPlace",
        "eventType",
        "12/12/2021",
        "12/12/2023",
        55,
        5,
        "eventId2",
        partecipants,
        applicants,
        qrCodes,
        0);
    applicants.add('my userID');
    qrCodes.add("asddsa");
    qrCodes.add("4112");
    String qrcodesUser = '';
    final userQrCode = fakeFirebaseFirestore.collection("userQrCodes");
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId2",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "notme",
      'firstFreeQrCode': 0,
    });
    databaseService.acceptApplicance(event2, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the qrCode from the fakeFirestore
    List<String> qrcodes = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == "eventId2")
                {qrcodes = List<String>.from(value.docs[i].get('qrCodeList'))}
            }
        });
    await tester.pump(Duration(seconds: 2));
    await userQrCode.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('user') == "my userID" &&
                  value.docs[i].get('event') == "eventId2")
                {qrcodesUser = value.docs[i].get('qrCode')}
            }
        });
    await tester.pump(Duration(seconds: 2));

    expect(qrcodes[0], "asddsa");

    expect(qrcodesUser, qrcodes[0]);
    expect(qrcodesUser, "asddsa");
  });

  testWidgets(
      'Checks after accepting an user that is receveing the correct qrCode with the firstFreeQrCode set to a value different to 0',
      (tester) async {
    Event event3 = Event(
        "managerId",
        "name",
        "urlImage",
        "description",
        0,
        0,
        "placeName",
        "typeOfPlace",
        "eventType",
        "12/12/2021",
        "12/12/2023",
        55,
        5,
        "eventId3",
        partecipants,
        applicants,
        qrCodes,
        1);
    applicants.add('my userID');
    qrCodes.add("asddsa");
    qrCodes.add("4112");
    qrCodes.add("4132");
    qrCodes.add("416423");
    String qrcodesUser = '';
    final userQrCode = fakeFirebaseFirestore.collection("userQrCodes");
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId3",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "notme",
      'firstFreeQrCode': 1,
    });
    await tester.pump(Duration(seconds: 2));

    databaseService.acceptApplicance(event3, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the qrCode from the fakeFirestore
    List<String> qrcodes = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == "eventId3")
                {qrcodes = List<String>.from(value.docs[i].get('qrCodeList'))}
            }
        });
    await tester.pump(Duration(seconds: 2));
    //get the user qrCode from the fakeFirestore
    await userQrCode.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('user') == "my userID" &&
                  value.docs[i].get('event') == "eventId3")
                {qrcodesUser = value.docs[i].get('qrCode')}
            }
        });
    await tester.pump(Duration(seconds: 2));

    expect(qrcodes[1], "4112");
    expect(qrcodesUser, "4112");
    expect(qrcodesUser, qrcodes[1]);
  });

  testWidgets(
      'Checks if the Refuse Applicance is refusing an user in the applicanceList when im the only user ',
      (tester) async {
    applicants.add('my userID');
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "notme",
      'firstFreeQrCode': 0,
    });
    databaseService.refuseApplicance(event, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });
    //get the list of the partecipants from the fakeFirestore
    List<String> firebaseApplicanceList = [];
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebaseApplicanceList =
                      List<String>.from(value.docs[i].get('applicants'))
                }
            }
        });

    expect(applicants.length, 0);
    expect(firebasePartecipantList.length, 0);
    expect(firebaseApplicanceList.length, 0);
  });

  testWidgets(
      'Checks if the Refuse Applicance is refusing an user in the applicanceList when there are more user ',
      (tester) async {
    applicants.add('my id1');
    applicants.add('my userID');
    applicants.add('my id2');
    applicants.add('my id3');
    await fakeFirebaseFirestore.collection("events").add({
      "eventId": "eventId",
      "applicants": applicants,
      "partecipants": partecipants,
      "qrCodeList": qrCodes,
      "manager": "notme",
      'firstFreeQrCode': 0,
    });
    databaseService.refuseApplicance(event, 'my userID');
    await tester.pump(Duration(seconds: 2));

    //get the list of the partecipants from the fakeFirestore
    List<String> firebasePartecipantList = [];
    final eventCollection = fakeFirebaseFirestore.collection("events");
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebasePartecipantList =
                      List<String>.from(value.docs[i].get('partecipants'))
                }
            }
        });
    //get the list of the partecipants from the fakeFirestore
    List<String> firebaseApplicanceList = [];
    await eventCollection.get().then((value) => {
          for (var i = 0; i < value.size; i++)
            {
              if (value.docs[i].get('eventId') == event.eventId)
                {
                  firebaseApplicanceList =
                      List<String>.from(value.docs[i].get('applicants'))
                }
            }
        });

    expect(applicants.length, 3);
    expect(firebasePartecipantList.length, 0);
    expect(firebaseApplicanceList.length, 3);
  });

  testWidgets(
      'Check that getCurrent returns null if currentUser not present in database',
      (tester) async {
    final userCollection = fakeFirebaseFirestore.collection("users");
    await userCollection.doc("notmyuserID").set({
      "uid": "notmyuserID",
      "email": "myemail",
      "name": "name",
      "surname": "surname",
      "password": "notme",
    });
    await tester.pump(Duration(seconds: 5));
    AppUser appuser = await databaseService.getCurrentAppUser();
    await tester.pump(Duration(seconds: 5));
    expect(appuser.getEmail, "");
    expect(appuser.name, "");
    expect(appuser.surname, "");
    expect(appuser.password, "");
  });

  testWidgets('Check that getCurrent returns the current AppUser if present',
      (tester) async {
    final userCollection = fakeFirebaseFirestore.collection("users");
    await userCollection.doc("my userID").set({
      "uid": "my userID",
      "email": "myemail",
      "name": "name",
      "surname": "surname",
      "password": "notme",
    });
    await tester.pump(Duration(seconds: 5));
    AppUser appuser = await databaseService.getCurrentAppUser();
    await tester.pump(Duration(seconds: 5));
    expect(appuser.uid, "my userID");
    expect(appuser.getEmail, "myemail");
    expect(appuser.name, "name");
    expect(appuser.surname, "surname");
    expect(appuser.password, "notme");
  });

  testWidgets('Check if the current user is an owner of a local',
      (tester) async {
    final userCollection = fakeFirebaseFirestore.collection("users");
    await userCollection.doc("my userID").set({
      "uid": "my userID",
      "email": "myemail",
      "name": "name",
      "surname": "surname",
      "password": "notme",
      "isowner": true
    });
    await tester.pump(Duration(seconds: 5));
    bool isOwner = await databaseService.isCurrentUserManager();
    await tester.pump(Duration(seconds: 5));
    expect(isOwner, true);
  });

  testWidgets('Check if the current user is NOT an owner of a local',
      (tester) async {
    final userCollection = fakeFirebaseFirestore.collection("users");
    await userCollection.doc("my userID").set({
      "uid": "my userID",
      "email": "myemail",
      "name": "name",
      "surname": "surname",
      "password": "notme",
      "isowner": false
    });
    await tester.pump(Duration(seconds: 5));
    bool isOwner = await databaseService.isCurrentUserManager();
    await tester.pump(Duration(seconds: 5));
    expect(isOwner, false);
  });

  testWidgets('Check that the current user has no local', (tester) async {
    final ownerLocalCollection =
        fakeFirebaseFirestore.collection("ownerLocals");
    await ownerLocalCollection.add({
      "owner": "not my userID",
      "longitude": 4.56,
      "localName": "local name",
      "localAddress": "local address",
      "latitude": 4.51,
    });
    await tester.pump(Duration(seconds: 5));
    List<Local> localList = await databaseService.getMyLocals();
    await tester.pump(Duration(seconds: 5));
    expect(localList.length, 0);
  });

  testWidgets('Check that the current user has 1 local', (tester) async {
    final ownerLocalCollection =
        fakeFirebaseFirestore.collection("ownerLocals");
    await ownerLocalCollection.add({
      "owner": "my userID",
      "longitude": 4.56,
      "localName": "local name",
      "localAddress": "local address",
      "latitude": 4.51,
    });
    await tester.pump(Duration(seconds: 5));
    List<Local> localList = await databaseService.getMyLocals();
    await tester.pump(Duration(seconds: 5));
    expect(localList.length, 1);
    expect(localList[0].owner, "my userID");
    expect(localList[0].latitude, 4.51);
    expect(localList[0].longitude, 4.56);
    expect(localList[0].localName, "local name");
    expect(localList[0].localAddress, "local address");
  });

  testWidgets('Check that the current user has more than 1 local',
      (tester) async {
    final ownerLocalCollection =
        fakeFirebaseFirestore.collection("ownerLocals");
    await ownerLocalCollection.add({
      "owner": "my userID",
      "longitude": 4.56,
      "localName": "local name",
      "localAddress": "local address",
      "latitude": 4.51,
    });

    await ownerLocalCollection.add({
      "owner": "my userID",
      "longitude": 5.56,
      "localName": "local name2",
      "localAddress": "local address2",
      "latitude": 5.51,
    });

    await tester.pump(Duration(seconds: 5));
    List<Local> localList = await databaseService.getMyLocals();
    await tester.pump(Duration(seconds: 5));
    expect(localList.length, 2);
    expect(localList[0].owner, "my userID");
    expect(localList[0].latitude, 4.51);
    expect(localList[0].longitude, 4.56);
    expect(localList[0].localName, "local name");
    expect(localList[0].localAddress, "local address");

    expect(localList[1].owner, "my userID");
    expect(localList[1].latitude, 5.51);
    expect(localList[1].longitude, 5.56);
    expect(localList[1].localName, "local name2");
    expect(localList[1].localAddress, "local address2");
  });

  testWidgets('Check that getEventById returns the correct event',
      (tester) async {
    final eventsCollection = fakeFirebaseFirestore.collection("events");
    await eventsCollection.add({
      'manager': event.managerId,
      'name': event.name,
      'urlImage': event.urlImage,
      'description': event.description,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'placeName': event.placeName,
      'typeOfPlace': event.typeOfPlace,
      'eventType': event.eventType,
      'dateBegin': event.dateBegin,
      'dateEnd': event.dateEnd,
      'maxPartecipants': event.maxPartecipants,
      'price': event.price,
      'qrCodeList': qrCodes,
      'partecipants': event.partecipants,
      'applicants': event.applicants,
      'eventId': event.eventId,
      'firstFreeQrCode': event.firstFreeQrCode,
    });
    await tester.pump(Duration(seconds: 5));
    Event eventFound = await databaseService.getEventByid(event.eventId);
    await tester.pump(Duration(seconds: 5));
    expect(eventFound.managerId, event.managerId);
    expect(eventFound.name, event.name);
    expect(eventFound.urlImage, event.urlImage);
    expect(eventFound.description, event.description);
    expect(eventFound.latitude, event.latitude);
    expect(eventFound.longitude, event.longitude);
    expect(eventFound.placeName, event.placeName);
    expect(eventFound.typeOfPlace, event.typeOfPlace);
    expect(eventFound.eventType, event.eventType);
    expect(eventFound.dateBegin, event.dateBegin);
    expect(eventFound.dateEnd, event.dateEnd);
    expect(eventFound.maxPartecipants, event.maxPartecipants);
    expect(eventFound.price, event.price);
    expect(eventFound.firstFreeQrCode, event.firstFreeQrCode);
    expect(eventFound.getQrCodeList, event.getQrCodeList);
    expect(eventFound.partecipants, event.partecipants);
    expect(eventFound.applicants, event.applicants);
  });

  testWidgets('Check that getEventById returns nothign when no event is found',
      (tester) async {
    final eventsCollection = fakeFirebaseFirestore.collection("events");
    await eventsCollection.add({
      'manager': event.managerId,
      'name': event.name,
      'urlImage': event.urlImage,
      'description': event.description,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'placeName': event.placeName,
      'typeOfPlace': event.typeOfPlace,
      'eventType': event.eventType,
      'dateBegin': event.dateBegin,
      'dateEnd': event.dateEnd,
      'maxPartecipants': event.maxPartecipants,
      'price': event.price,
      'qrCodeList': qrCodes,
      'partecipants': event.partecipants,
      'applicants': event.applicants,
      'eventId': event.eventId,
      'firstFreeQrCode': event.firstFreeQrCode,
    });
    await tester.pump(Duration(seconds: 5));
    Event eventFound = await databaseService.getEventByid("RandomEventID");
    await tester.pump(Duration(seconds: 5));
    expect(eventFound.managerId, "");
    expect(eventFound.name, "");
    expect(eventFound.urlImage, "");
    expect(eventFound.description, "");
    expect(eventFound.latitude, 0);
    expect(eventFound.longitude, 0);
    expect(eventFound.placeName, "");
    expect(eventFound.typeOfPlace, "");
    expect(eventFound.eventType, "");
    expect(eventFound.dateBegin, "");
    expect(eventFound.dateEnd, "");
    expect(eventFound.maxPartecipants, 0);
    expect(eventFound.price, 0);
    expect(eventFound.firstFreeQrCode, 0);
    expect(eventFound.getQrCodeList, []);
    expect(eventFound.partecipants, []);
    expect(eventFound.applicants, []);
  });

  testWidgets('Check that getQrCodeByUserEvent returns the correct qrCode',
      (tester) async {
    final userQrCodeCollection =
        fakeFirebaseFirestore.collection("userQrCodes");
    await userQrCodeCollection.add({
      "event": event.eventId,
      "user": "my userID",
      "qrCode": "123456789asd"
    });

    await userQrCodeCollection.add({
      "event": event.eventId,
      "user": "my uasdserID",
      "qrCode": "1234fas56789asd"
    });

    await userQrCodeCollection.add({
      "event": event.eventId,
      "user": "my uasdsfaserID",
      "qrCode": "123adsdas456789asd"
    });

    await tester.pump(Duration(seconds: 2));
    String qrCode =
        await databaseService.getQrCodeByUserEvent(event, "my userID");
    await tester.pump(Duration(seconds: 2));
    expect(qrCode, "123456789asd");
  });

  testWidgets(
      'Check that getQrCodeByUserEvent returns noting if no qrCode is found with the correct event and user',
      (tester) async {
    final userQrCodeCollection =
        fakeFirebaseFirestore.collection("userQrCodes");
    await userQrCodeCollection.add({
      "event": event.eventId,
      "user": "noasdserID",
      "qrCode": "123456789asd"
    });

    await userQrCodeCollection.add({
      "event": event.eventId,
      "user": "my uasdserID",
      "qrCode": "1234fas56789asd"
    });

    await userQrCodeCollection.add({
      "event": event.eventId,
      "user": "my uasdsfaserID",
      "qrCode": "123adsdas456789asd"
    });

    await tester.pump(Duration(seconds: 2));
    String qrCode =
        await databaseService.getQrCodeByUserEvent(event, "my userID");
    await tester.pump(Duration(seconds: 2));
    expect(qrCode, "");
  });
}
