import 'dart:developer';
import 'dart:io';

import 'package:event_handler/models/local.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Create_Event extends StatefulWidget {
  @override
  _Create_EventState createState() => _Create_EventState();
  const Create_Event({Key? key, required this.databaseService})
      : super(key: key);
  final DatabaseService databaseService;
}

class _Create_EventState extends State<Create_Event> {
  ImagePicker image = ImagePicker();
  File? file;
  String _urlImage = '';

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
    });
  }

  uploadFile() async {
    var imageFile =
        await FirebaseStorage.instance.ref().child("path").child("/.jpg");
    UploadTask task = imageFile.putFile(file!);
    TaskSnapshot snapshot = await task;
    //for downloading
    _urlImage = await snapshot.ref.getDownloadURL();
    print(_urlImage);
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final locals = ['', '', ''];
  String localName = '';
  final EventTypes = ['Public', 'Private'];
  final TypeOfPlace = [
    'Cinema',
    'Theatre',
    'Restaurant',
    'Bar/Pub',
    'Disco',
    'Private Setting'
  ];
  String? _eventType;
  String? _typeOfPlace;
  String _name = '';
  String _address = '';
  String _placeName = '';
  String _description = '';
  String _maxPartecipants = '';
  final addressesList = [];

  String _price = '';
  DateTime? _eventDate;

  Widget _buildImage() {
    return InkWell(
      onTap: () {
        getImage();
      },
      child: CircleAvatar(
        radius: 88,
        backgroundImage: file == null
            ? AssetImage('assets/facebook.png')
            : FileImage(File(file!.path)) as ImageProvider,
      ),
    );
  }

  Widget _buildName() {
    return TextFormField(
      key: Key('name'),
      decoration: InputDecoration(labelText: 'Name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Name is Required';
        }
      },
      onChanged: (value) {
        setState(() {
          _name = value.trim();
        });
      },
    );
  }

  Widget _buildAddress() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Address'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Address is Required';
        }
      },
      onChanged: (value) {
        setState(() {
          _address = value.trim();
        });
      },
    );
  }

  Widget _buildPlaceName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Place Name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Name is Required';
        }
      },
      onChanged: (value) {
        setState(() {
          _placeName = value.trim();
        });
      },
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      key: Key("description"),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(labelText: 'Description'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Descripion is Required';
        }
      },
      onChanged: (value) {
        setState(() {
          _description = value.trim();
        });
      },
    );
  }

  Widget _buildMaxPartecipantNumber() {
    return TextFormField(
      key: Key("max partecipants"),
      decoration: const InputDecoration(
        labelText: 'Max number of Partecipants',
      ),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Max number of partecipant is Required';
        }
      },
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _maxPartecipants = value.trim();
        });
      },
    );
  }

  Widget _buildPrice() {
    return TextFormField(
      key: Key("price"),
      decoration: const InputDecoration(
        labelText: 'Price (€)',
      ),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Price (€) is Required';
        }
      },
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _price = value.trim();
        });
      },
    );
  }

  Widget _buildEventType() {
    return DropdownButtonFormField<String>(
      key: Key("event type"),
      validator: (String? value) {
        if (value == null) {
          return 'Event type is Required';
        }
      },
      hint: new Text("Select the type of the event"),
      isExpanded: true,
      value: _eventType,
      items: EventTypes.map(buildMenuItems).toList(),
      onChanged: (value) => setState(() => _eventType = value!),
    );
  }

  Widget _buildTypeOfPlace() {
    return DropdownButtonFormField<String>(
      key: Key("place type"),
      validator: (String? value) {
        if (value == null) {
          return 'Type of place is Required';
        }
      },
      hint: new Text("Select the type of the local"),
      isExpanded: true,
      value: _typeOfPlace,
      items: TypeOfPlace.map(buildMenuItems).toList(),
      onChanged: (value) => setState(() => _typeOfPlace = value!),
    );
  }

  DropdownMenuItem<String> buildMenuItems(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );

  Widget _buildDataPicker(BuildContext context) {
    return ElevatedButton(
      key: Key('data button'),
      child: Text(_eventDate == null
          ? 'Select Date'
          : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'),
      onPressed: () async {
        pickDate(context);
      },
    );
  }

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      selectableDayPredicate: _decideWhichDayToEnable,
    );
    if (newDate == null) return;

    setState(() {
      _eventDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    {
      return Scaffold(
          appBar: AppBar(title: Text('Create_Event')),
          body: Container(
            margin: EdgeInsets.all(24),
            child: Form(
              key: _key,
              child: ListView(
                key: Key('list view'),
                children: <Widget>[
                  _buildImage(),
                  ElevatedButton(
                    key: Key('upload image button'),
                    onPressed: () {
                      uploadFile();
                    },
                    child: Text("Upload Image"),
                  ),
                  SizedBox(height: 20),
                  _buildName(),
                  SizedBox(height: 20),
                  _buildDescription(),
                  SizedBox(height: 20),
                  FutureBuilder<List<Local>>(
                      future: widget.databaseService.getMyLocals(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Local>> myLocals) {
                        if (myLocals.hasError)
                          return Container(
                            child: Text('some error may have occured'),
                          );
                        return DropdownButtonFormField<String>(
                          validator: (String? value) {
                            if (value == null) {
                              return 'Local is Required';
                            }
                          },
                          isExpanded: true,
                          key: Key("place name"),
                          hint: new Text("Select a local"),
                          items: myLocals.data != null
                              ? myLocals.data!
                                  .map((local) => DropdownMenuItem(
                                        child: Text(local.localName),
                                        value: local.localName,
                                      ))
                                  .toList()
                              : locals.map(buildMenuItems).toList(),
                          onChanged: (value) =>
                              setState(() => localName = value!),
                        );
                      }),
                  SizedBox(height: 20),
                  _buildTypeOfPlace(),
                  SizedBox(height: 20),
                  _buildEventType(),
                  SizedBox(height: 20),
                  _buildDataPicker(context),
                  SizedBox(height: 20),
                  _buildPrice(),
                  SizedBox(height: 20),
                  _buildMaxPartecipantNumber(),
                  SizedBox(height: 20),
                  ElevatedButton(
                      key: Key('create event button'),
                      child: const Text('Create Event'),
                      onPressed: () async {
                        if (!_key.currentState!.validate()) {
                          return;
                        }

                        await widget.databaseService.createEventData(
                            _name,
                            _urlImage,
                            _description,
                            _address,
                            _placeName,
                            _typeOfPlace,
                            _eventType,
                            _eventDate,
                            _maxPartecipants,
                            _price,
                            0,
                            localName);

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => Wrapper()),
                            (Route<dynamic> route) => false);
                      }),
                ],
              ),
            ),
          ));
    }
  }
}
