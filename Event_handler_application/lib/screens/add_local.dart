import 'dart:io';

import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddLocal extends StatefulWidget {
  const AddLocal({Key? key}) : super(key: key);

  @override
  _AddLocalState createState() => _AddLocalState();
}

class _AddLocalState extends State<AddLocal> {
  String _localAddress = '';
  String _localName = '';
  final AuthService _authService = AuthService();

  File? file;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Widget _buildAddress() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Address of your local'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Address is Required';
        }
      },
      onChanged: (value) {
        setState(() {
          _localAddress = value.trim();
        });
      },
    );
  }

  Widget _buildLocalName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Local name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Local name is Required';
        }
      },
      onChanged: (value) {
        setState(() {
          _localName = value.trim();
        });
      },
    );
  }

  Future selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final path = result.files.single.path!;
      setState(() => file = File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Local')),
        body: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _key,
            child: ListView(
              children: <Widget>[
                _buildAddress(),
                SizedBox(height: 20),
                _buildLocalName(),
                SizedBox(height: 20),
                ElevatedButton(
                    child: Text('Select file'),
                    onPressed: () async {
                      selectFile();
                    }),
                ElevatedButton(
                    child: Text('Add Local'),
                    onPressed: () async {
                      await DatabaseService(_authService.getCurrentUser()!.uid)
                          .addLocalForCurrentUser(_localAddress, _localName);
                    })
              ],
            ),
          ),
        ));
  }
}