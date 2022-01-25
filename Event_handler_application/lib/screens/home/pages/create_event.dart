import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:event_handler/models/local.dart';
import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/screens/home/pages/custom_rect_tween.dart';
import 'package:event_handler/screens/home/pages/hero_dialogue_route.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
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
  String _price = '';

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
    });
  }

  uploadFile() async {
    var imageFile = await FirebaseStorage.instance
        .ref()
        .child(_name + "_" + _eventDate.toString())
        .child("/" + _name + "_" + _eventDate.toString() + ".jpg");
    UploadTask task = imageFile.putFile(file!);
    TaskSnapshot snapshot = await task;
    //for downloading
    String url = await snapshot.ref.getDownloadURL();
    print(url);
    setState(() {
      _urlImage = url;
    });
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

  DateTime? _eventDate;
  // List<Local> myLocals2 = [];
  // @override
  // void initState() {
  //   func() async {
  //     var tempList = await DatabaseService(_authService.getCurrentUser()!.uid)
  //         .getMyLocals();
  //     setState(() {
  //       myLocals2 = tempList;
  //     });
  //   }
  // }

  Widget _buildImage() {
    // return Stack(
    //   children: [
    //     InkWell(
    //       onTap: () {
    //         getImage();
    //       },
    //       child: CircleAvatar(
    //         backgroundColor: Colors.white,
    //         foregroundColor: Colors.white,
    //         radius: 60,
    //         backgroundImage: file == null
    //             ? AssetImage('assets/upload1.png')
    //             : FileImage(File(file!.path)) as ImageProvider,
    //       ),
    //     ),
    //   ],
    // );
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFF5F6F9),
            backgroundImage: file == null
                ? AssetImage('assets/video_image.png')
                : FileImage(File(file!.path)) as ImageProvider,
          ),
          Positioned(
              bottom: 0,
              right: -25,
              child: RawMaterialButton(
                onPressed: () {
                  getImage();
                },
                elevation: 2.0,
                fillColor: Color(0xFFF5F6F9),
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.black,
                ),
                padding: EdgeInsets.all(15.0),
                shape: CircleBorder(),
              )),
        ],
      ),
    );
  }

  Widget _buildName() {
    return TextFormField(
      key: Key('name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'The Name of the Event is required';
        }
      },
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        helperText: ' ',
        contentPadding: EdgeInsets.only(
          top: 0,
          bottom: 5,
          left: 48,
        ),
        errorBorder: OutlineInputBorder(
          gapPadding: 25,
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
          borderSide: BorderSide(width: 0.7),
        ),
        focusedErrorBorder: OutlineInputBorder(
          gapPadding: 20,
          borderRadius: BorderRadius.circular(50),
          borderSide: new BorderSide(
            color: Colors.red.shade700,
            width: 2,
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: 'Enter the Name of the Event',
        hintStyle: TextStyle(fontSize: 14, color: Colors.black),
      ),
      onChanged: (value) {
        setState(() {
          _name = value.trim();
          print(_name);
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
          // _maxPartecipants = value.trim();
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
          // _price = value.trim();
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
    final Local nullList;
    Size size = MediaQuery.of(context).size;
    {
      return Scaffold(
        body: Form(
          key: _key,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF121B22),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height -
                            size.height / 4.2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                            child: ListView(
                              key: Key("list view"),
                              padding: const EdgeInsets.all(16),
                              children: [
                                //name + image
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "1",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.event,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Name of the Event",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  _name,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .multiline,
                                                              maxLines: null,
                                                              cursorColor:
                                                                  Colors.black,
                                                              validator:
                                                                  (String?
                                                                      value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return 'Name is Required';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  hintText:
                                                                      'Write the name...',
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _name = value
                                                                      .trim();
                                                                  print(_name);
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          _buildImage(),
                                                          Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85),
                                                            child:
                                                                ElevatedButton(
                                                              key: Key(
                                                                  'upload image'),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Colors
                                                                    .white,
                                                                onPrimary:
                                                                    Colors
                                                                        .white,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                uploadFile();
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .upload,
                                                                      color: Colors
                                                                          .black),
                                                                  Text(
                                                                    "Upload Image",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "1",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.event,
                                                        color: Colors.black),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      "Name of the Event",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                // const Divider(
                                                //   height: 5,
                                                //   thickness: 1.5,
                                                //   indent: 160,
                                                //   endIndent: 160,
                                                //   color: Colors.black,
                                                // ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                _buildImage(),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "2",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .description,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Description of the Event",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  _description,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .multiline,
                                                              maxLines: null,
                                                              cursorColor:
                                                                  Colors.black,
                                                              validator:
                                                                  (String?
                                                                      value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return 'Descripion is Required';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  hintText:
                                                                      'Write the description...',
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _description =
                                                                      value
                                                                          .trim();
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "2",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.description,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      "Description of the Event",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),

                                //place of the event
                                GestureDetector(
                                  key: Key("Place of the Event"),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "3",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.place,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Place of the Event",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                            ),
                                                            child: FutureBuilder<
                                                                    List<
                                                                        Local>>(
                                                                future: widget
                                                                    .databaseService
                                                                    .getMyLocals(),
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            List<Local>>
                                                                        myLocals) {
                                                                  if (myLocals
                                                                      .hasError)
                                                                    return Container(
                                                                      child: Text(
                                                                          'Some error may have occured'),
                                                                    );

                                                                  return DropdownButtonFormField2(
                                                                    value:
                                                                        _typeOfPlace,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelStyle:
                                                                          TextStyle(
                                                                              fontWeight: FontWeight.w200),
                                                                      //Add isDense true and zero Padding.
                                                                      //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                      isDense:
                                                                          true,
                                                                      contentPadding:
                                                                          EdgeInsets.symmetric(
                                                                              horizontal: 8),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30),
                                                                      ),
                                                                      //Add more decoration as you want here
                                                                      //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                    ),
                                                                    isExpanded:
                                                                        true,
                                                                    hint:
                                                                        const Text(
                                                                      'Select the Place of the Event...',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .arrow_drop_down,
                                                                      color: Colors
                                                                          .black45,
                                                                    ),
                                                                    iconSize:
                                                                        30,
                                                                    buttonHeight:
                                                                        50,
                                                                    buttonPadding: const EdgeInsets
                                                                            .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                    dropdownDecoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    items: myLocals.data !=
                                                                            null
                                                                        ? myLocals
                                                                            .data!
                                                                            .map((local) =>
                                                                                DropdownMenuItem<
                                                                                    String>(
                                                                                  child: Text(
                                                                                    local.localName,
                                                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                  value: local.localName,
                                                                                ))
                                                                            .toList()
                                                                        : locals
                                                                            .map(buildMenuItems)
                                                                            .toList(),
                                                                    validator:
                                                                        (value) {
                                                                      if (value ==
                                                                          null) {
                                                                        return 'Please select the Place of the Event.';
                                                                      }
                                                                    },
                                                                    onChanged: (value) =>
                                                                        setState(() =>
                                                                            localName =
                                                                                value.toString()),
                                                                  );
                                                                }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "3",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.place,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Place of the Event",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  key: Key("Type of Place"),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "4",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.flag,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              Text(
                                                                "Type of Place",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            child:
                                                                DropdownButtonFormField2(
                                                              value:
                                                                  _typeOfPlace,
                                                              decoration:
                                                                  InputDecoration(
                                                                labelStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200),
                                                                //Add isDense true and zero Padding.
                                                                //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                //Add more decoration as you want here
                                                                //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                              ),
                                                              isExpanded: true,
                                                              hint: const Text(
                                                                'Select the Type of Place...',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color: Colors
                                                                    .black45,
                                                              ),
                                                              iconSize: 30,
                                                              buttonHeight: 50,
                                                              buttonPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      right:
                                                                          20),
                                                              dropdownDecoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              items: TypeOfPlace
                                                                  .map((item) =>
                                                                      DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            item,
                                                                        child:
                                                                            Text(
                                                                          item,
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      )).toList(),
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                    null) {
                                                                  return 'Please select type of place.';
                                                                }
                                                              },
                                                              onChanged: (value) =>
                                                                  setState(() =>
                                                                      _typeOfPlace =
                                                                          value
                                                                              .toString()),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "4",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.flag,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Type of Place",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  key: Key("Privacy of the Event"),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "5",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.security,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Privacy of the Event",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            child:
                                                                DropdownButtonFormField2(
                                                              value: _eventType,
                                                              decoration:
                                                                  InputDecoration(
                                                                labelStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200),
                                                                //Add isDense true and zero Padding.
                                                                //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                //Add more decoration as you want here
                                                                //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                              ),
                                                              isExpanded: true,
                                                              hint: const Text(
                                                                'Select the Privacy of the Event...',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color: Colors
                                                                    .black45,
                                                              ),
                                                              iconSize: 30,
                                                              buttonHeight: 50,
                                                              buttonPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20,
                                                                      right:
                                                                          20),
                                                              dropdownDecoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              items: EventTypes
                                                                  .map((item) =>
                                                                      DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            item,
                                                                        child:
                                                                            Text(
                                                                          item,
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      )).toList(),
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                    null) {
                                                                  return 'Please select the privacy of the event.';
                                                                }
                                                              },
                                                              onChanged:
                                                                  (value) =>
                                                                      setState(
                                                                () => _eventType =
                                                                    value
                                                                        .toString(),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "5",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.security,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Privacy of the Event",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "6",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  "Date",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ]),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85),
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                primary: Colors
                                                                    .white,
                                                                onPrimary:
                                                                    Colors
                                                                        .white,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                pickDate(
                                                                    context);
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    _eventDate ==
                                                                            null
                                                                        ? 'Select Date'
                                                                        : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          // _buildDataPicker(context),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "6",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.calendar_today,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Date",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "7",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.euro,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Price",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  _price,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _price = value
                                                                      .trim();
                                                                });
                                                              },
                                                              cursorColor:
                                                                  Colors.black,
                                                              validator:
                                                                  (String?
                                                                      value) {
                                                                if (value!
                                                                        .isEmpty ||
                                                                    value ==
                                                                        '') {
                                                                  return 'Price is Required';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  hintText:
                                                                      'Write the Price (€)...',
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "7",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.euro,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Price",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: Hero(
                                            tag: "8",
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin, end: end);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Color(0xFF8596a0),
                                                child: SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.people,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Maximum of Partecipants",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .black12,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  _maxPartecipants,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _maxPartecipants =
                                                                      value
                                                                          .trim();
                                                                });
                                                              },
                                                              cursorColor:
                                                                  Colors.black,
                                                              validator:
                                                                  (String?
                                                                      value) {
                                                                if (value!
                                                                        .isEmpty ||
                                                                    value ==
                                                                        '') {
                                                                  return 'Max Partecipants is Required';
                                                                }
                                                              },
                                                              decoration: InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  hintText:
                                                                      'Write the Number of Partecipants...',
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "8",
                                    createRectTween: (begin, end) {
                                      return CustomRectTween(
                                          begin: begin, end: end);
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Material(
                                          color: Color(0xFF8596a0),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.people,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Maximum of Partecipants",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 3, bottom: 3),
                                                    width: 30,
                                                    height: 3,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black45
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                SizedBox(height: size.height / 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        height: size.height / 16,
                        margin: EdgeInsets.only(top: 10, bottom: 0),
                        width: size.width - size.width / 6,
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
                          child: Text(
                            'Create Event',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () async {
                            if (!_key.currentState!.validate()) {
                              log('Error creation event');
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
                                MaterialPageRoute(
                                    builder: (context) => Wrapper()),
                                (Route<dynamic> route) => false);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
