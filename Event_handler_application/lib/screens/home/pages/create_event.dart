import 'dart:developer';

import 'package:event_handler/models/local.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Create_Event extends StatefulWidget {
  @override
  _Create_EventState createState() => _Create_EventState();
}

class _Create_EventState extends State<Create_Event> {
  final AuthService _authService = AuthService();
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

  Widget _buildName() {
    return TextFormField(
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
                children: <Widget>[
                  _buildName(),
                  SizedBox(height: 20),
                  _buildDescription(),
                  SizedBox(height: 20),
                  FutureBuilder<List<Local>>(
                      future:
                          DatabaseService(_authService.getCurrentUser()!.uid)
                              .getMyLocals(),
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
                      child: const Text('Create Event'),
                      onPressed: () async {
                        if (!_key.currentState!.validate()) {
                          return;
                        }
                        await DatabaseService(
                                _authService.getCurrentUser()!.uid)
                            .createEventData(
                                _name,
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
