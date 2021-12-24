
import 'dart:developer';

import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/home/home.dart';
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
  final AuthService _authService= AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final EventTypes= ['Public', 'Private'];

  String? _eventType;
  String _name='';
  String _description='';
  int maxPartecipants=0;
  DateTime? _eventDate;

  Widget _buildName(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      validator: (String? value){
        if(value!.isEmpty){
          return 'Name is Required';
        }
      },
      onChanged: (value){
      setState(() {
      _name= value.trim();
        });
      },
    );
  }

    Widget _buildDescription(){
      return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(labelText: 'Description'),
      validator: (String? value){
        if(value!.isEmpty){
          return 'Descripion is Required';
        }
      },
      onChanged: (value){
      setState(() {
      _description= value.trim();
        });
      },
    );
  }

  Widget _buildPartecipantNumber(){
    return TextFormField(
      decoration: const InputDecoration(
       labelText: 'Max number of Partecipants',
       ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildEventType(){
    return DropdownButton<String>(
      isExpanded: true,
      value: _eventType,
      items: EventTypes.map(buildMenuItems).toList(),
      onChanged: (value) =>  setState(() => _eventType = value!),
  );
  }

  DropdownMenuItem<String> buildMenuItems(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize:20,),
    ),
  );

  Widget _buildDataPicker(BuildContext context) {
    return ElevatedButton(
      child: Text(
        _eventDate==null 
      ? 'Select Date'
      : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'),
      onPressed: () async{pickDate(context);}, 
      );
  }

  Future pickDate (BuildContext context) async{
    final initialDate= DateTime.now();
    final newDate= await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year-5), 
      lastDate: DateTime(DateTime.now().year+5),
      );
      if (newDate == null) return;

      setState(() {
        _eventDate=newDate;
      });
  }

  @override
  Widget build(BuildContext context) {{
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
            _buildEventType(),
            SizedBox(height: 20),
            _buildPartecipantNumber(),
            SizedBox(height: 20),
            _buildDataPicker(context),
            SizedBox(height: 100),
            ElevatedButton(
              child: const Text('Create Event'),
              onPressed: () async{
                await DatabaseService(_authService.getCurrentUser()!.uid).createEventData(_name, _description, _eventType, _eventDate, maxPartecipants);
                
                //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
              }), 
            ],
          ),
        ),
      ),
    );}
  }
}