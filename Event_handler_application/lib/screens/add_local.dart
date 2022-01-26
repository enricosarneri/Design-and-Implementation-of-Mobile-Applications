import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddLocal extends StatefulWidget {
  const AddLocal({Key? key, required this.authService}) : super(key: key);
  final AuthService authService;
  @override
  _AddLocalState createState() => _AddLocalState();
}

class _AddLocalState extends State<AddLocal> {
  String _localAddress = '';
  String _localName = '';
  late Timer _timer;
  File? file;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Widget _buildAddress() {
    // return TextFormField(
    //   decoration: InputDecoration(labelText: 'Address of your local'),
    //   validator: (String? value) {
    //     if (value!.isEmpty) {
    //       return 'Address is Required';
    //     }
    //   },
    //   onChanged: (value) {
    //     setState(() {
    //       _localAddress = value.trim();
    //     });
    //   },
    // );

    return TextFormField(
      style: TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        // errorStyle: TextStyle(height: 0.7),
        filled: true,
        fillColor: Colors.black12.withOpacity(0.4),
        helperText: ' ',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 30,
        ),
        errorBorder: OutlineInputBorder(
          gapPadding: 10,
          borderRadius: BorderRadius.circular(50),
          borderSide: new BorderSide(
            color: Colors.red.shade700,
          ),
        ),
        border: OutlineInputBorder(
          gapPadding: 25,
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(width: 0.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          gapPadding: 5,
          borderRadius: BorderRadius.circular(50),
          borderSide: new BorderSide(
            color: Colors.red.shade700,
            width: 2,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: 'Enter the Address of the Local...',
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(fontSize: 16, color: Colors.white),
        labelText: "Local Address",
      ),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Address is required';
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
    // return TextFormField(
    //   decoration: InputDecoration(labelText: 'Local name'),
    //   validator: (String? value) {
    //     if (value!.isEmpty) {
    //       return 'Local name is Required';
    //     }
    //   },
    //   onChanged: (value) {
    //     setState(() {
    //       _localName = value.trim();
    //     });
    //   },
    // );
    return TextFormField(
      style: TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        // errorStyle: TextStyle(height: 0.7),
        filled: true,
        fillColor: Colors.black12.withOpacity(0.4),
        helperText: ' ',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: 0,
          bottom: 0,
          left: 30,
        ),
        errorBorder: OutlineInputBorder(
          gapPadding: 10,
          borderRadius: BorderRadius.circular(50),
          borderSide: new BorderSide(
            color: Colors.red.shade700,
          ),
        ),
        border: OutlineInputBorder(
          gapPadding: 25,
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(width: 0.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          gapPadding: 5,
          borderRadius: BorderRadius.circular(50),
          borderSide: new BorderSide(
            color: Colors.red.shade700,
            width: 2,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: 'Enter the Name of the Local...',
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(fontSize: 16, color: Colors.white),
        labelText: "Local Name",
      ),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Name is required';
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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Add Local',
          ),
          backgroundColor: Color(0xFF121B22),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          color: Color(0xFF121B22),
          child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildAddress(),
                SizedBox(height: 12),
                _buildLocalName(),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 16,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //  shadowColor: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Select File',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        selectFile();
                      }),
                ),
                SizedBox(height: 20),
                Align(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0),
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 16,
                  child: ElevatedButton(
                      key: Key('Add local button'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //  shadowColor: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_location_alt,
                            color: Color(0xFF121B22),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Add Local',
                            style: TextStyle(
                                color: Color(0xFF121B22), fontSize: 16),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        if (!_key.currentState!.validate()) {
                          log('Error adding the local');
                          return;
                        }
                        await DatabaseService(
                                widget.authService.getCurrentUser()!.uid,
                                FirebaseFirestore.instance)
                            .addLocalForCurrentUser(_localAddress, _localName);
                        showDialog(
                            context: context,
                            builder: (BuildContext builderContext) {
                              _timer = Timer(Duration(milliseconds: 1200), () {
                                Navigator.of(context).pop();
                              });

                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: 50, left: 12, right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  elevation: 20,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.8),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      'Your local has been added successfully!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }).then((val) {
                          if (_timer.isActive) {
                            _timer.cancel();
                          }
                        });
                        Navigator.pop(
                          context,
                        );
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
