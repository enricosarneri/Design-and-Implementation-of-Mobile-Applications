import 'dart:async';
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
import 'package:intl/intl.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return WideLayout(databaseService: widget.databaseService);
          } else {
            return NarrowLayout(databaseService: widget.databaseService);
          }
        },
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  final DatabaseService? databaseService;

  @override
  NarrowLayout({Key? key, this.databaseService}) : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  ImagePicker image = ImagePicker();
  File? file;
  String _urlImage = '';
  String _price = '';

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    if (img!.path != null) {
      setState(() {
        file = File(img.path);
      });
    } else {
      return;
    }
  }

  uploadFile() async {
    var imageFile = await FirebaseStorage.instance
        .ref()
        .child(_name + "_" + _eventDateBegin.toString())
        .child("/" + _name + "_" + _eventDateBegin.toString() + ".jpg");
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
  String? localName;
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

  DateTime _eventDateBegin = DateTime.now(); //viene passata questa al db
  DateTime _eventDateEnd = DateTime.now(); //viene passata questa al db

  DateTime? _startEventDate;
  TimeOfDay _startEventTime = TimeOfDay.now();

  DateTime? _endEventDate;
  TimeOfDay _endEventTime = TimeOfDay.now();

  late Timer _timer;

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
      height: 100,
      width: 100,
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

  Widget _buildImage1() {
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
      height: 100,
      width: 100,
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

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  Future pickStartDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 2),
        selectableDayPredicate: _decideWhichDayToEnable,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF121B22), // header background color
                secondary: Colors.white,
                primaryVariant: Colors.white,
                secondaryVariant: Colors.white,
                onPrimary: Colors.white, // header text color
                onSurface: Colors.transparent,
                onBackground: Colors.white,
                onSecondary: Colors.white,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Color(0xFF121B22), // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newDate == null) return;

    setState(() {
      _startEventDate = newDate;
      _eventDateBegin = _startEventDate!;
    });
  }

  Future pickStartTime(BuildContext context) async {
    final initialTime = TimeOfDay.now();
    final newTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                primaryVariant: Colors.white, // header background color
                secondary: Color(0xFF121B22),
                onPrimary: Color(0xFF121B22),
                onSecondary: Colors.red,
                onBackground: Colors.white,
                secondaryVariant: Colors.red,
                surface: Color(0xFF121B22),
                onSurface: Colors.white,
                background: Colors.green,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newTime == null) return;

    setState(() {
      _startEventTime = newTime;
      _eventDateBegin = new DateTime(
          _eventDateBegin.year,
          _eventDateBegin.month,
          _eventDateBegin.day,
          _eventDateBegin.hour,
          _eventDateBegin.minute);
    });
  }

  Future pickEndDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 2),
        selectableDayPredicate: _decideWhichDayToEnable,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF121B22), // header background color
                secondary: Colors.white,
                primaryVariant: Colors.white,
                secondaryVariant: Colors.white,
                onPrimary: Colors.white, // header text color
                onSurface: Colors.transparent,
                onBackground: Colors.white,
                onSecondary: Colors.white,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Color(0xFF121B22), // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newDate == null) return;

    setState(() {
      _endEventDate = newDate;
      _eventDateEnd = _endEventDate!;
    });
  }

  Future pickEndTime(BuildContext context) async {
    final initialTime = TimeOfDay.now();
    final newTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                primaryVariant: Colors.white, // header background color
                secondary: Color(0xFF121B22),
                onPrimary: Color(0xFF121B22),
                onSecondary: Colors.red,
                onBackground: Colors.white,
                secondaryVariant: Colors.red,
                surface: Color(0xFF121B22),
                onSurface: Colors.white,
                background: Colors.green,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newTime == null) return;

    setState(() {
      _endEventTime = newTime;
      _eventDateEnd = new DateTime(_eventDateEnd.year, _eventDateEnd.month,
          _eventDateEnd.day, _endEventTime.hour, _endEventTime.minute);
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
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
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
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          // const SizedBox(
                                                          //   height: 5,
                                                          // ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                                  print(
                                                                      localName);
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          _buildImage(),
                                                          Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85,
                                                                    vertical:
                                                                        5),
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
                                                              child:
                                                                  SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
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
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
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
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: <Widget>[
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.event,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          "Name of the Event",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: size.height / 20,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8,
                                                        horizontal: 30),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black12
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: TextFormField(
                                                      readOnly: true,
                                                      initialValue: _name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          new InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '',
                                                      ),
                                                      validator:
                                                          (String? value) {
                                                        if (value!.isEmpty) {
                                                          return 'Name is Required';
                                                        }
                                                      },
                                                    ),
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
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  _buildImage1(),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                ],
                                              ),
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
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: _description,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return 'Description is Required';
                                                      }
                                                    },
                                                  ),
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
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
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
                                                                    .databaseService!
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
                                                                    // value:
                                                                    //     localName,
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
                                                                        size.height /
                                                                            20,
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
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: localName,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return 'Place of the Event is Required';
                                                      }
                                                    },
                                                  ),
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
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
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
                                                              buttonHeight:
                                                                  size.height /
                                                                      20,
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
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: _typeOfPlace,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return 'Type of place is Required';
                                                      }
                                                    },
                                                  ),
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
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
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
                                                              buttonHeight:
                                                                  size.height /
                                                                      20,
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
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: _eventType,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return 'Privacy of the Event is Required';
                                                      }
                                                    },
                                                  ),
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
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .timer_outlined,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  "Start Date-Time",
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
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    25,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85),
                                                            child: SizedBox(
                                                              height: double
                                                                  .infinity,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Colors
                                                                      .white,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  pickStartDate(
                                                                      context);
                                                                },
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        _eventDateBegin ==
                                                                                null
                                                                            ? 'Select End Date'
                                                                            : 'Start date: ${_eventDateBegin.day}/${_eventDateBegin.month}/${_eventDateBegin.year}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    25,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85),
                                                            child: SizedBox(
                                                              height: double
                                                                  .infinity,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Colors
                                                                      .white,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  pickStartTime(
                                                                      context);
                                                                },
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        _startEventTime ==
                                                                                null
                                                                            ? 'Select End Time'
                                                                            : 'Start Time: ${_startEventTime.hour}:${_startEventTime.minute}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
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
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Column(
                                                children: <Widget>[
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .timer_outlined,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Start Date-Time",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: size.height / 20,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8,
                                                        horizontal: 30),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black12
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: TextFormField(
                                                      readOnly: true,
                                                      initialValue: DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  _eventDateBegin) +
                                                          " " +
                                                          _startEventTime.hour
                                                              .toString() +
                                                          ":" +
                                                          _startEventTime.minute
                                                              .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          new InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '',
                                                      ),
                                                      validator:
                                                          (String? value) {
                                                        if (value!.isEmpty) {
                                                          return ' Start Date-Time is Required';
                                                        }
                                                      },
                                                    ),
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
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                            tag: "15",
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
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .timer_outlined,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  "End Date-Time",
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
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    25,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85),
                                                            child: SizedBox(
                                                              height: double
                                                                  .infinity,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Colors
                                                                      .white,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  pickEndDate(
                                                                      context);
                                                                },
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        _eventDateEnd ==
                                                                                null
                                                                            ? 'Select End Date'
                                                                            : 'End Date: ${_eventDateEnd.day}/${_eventDateEnd.month}/${_eventDateEnd.year}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    25,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        85),
                                                            child: SizedBox(
                                                              height: double
                                                                  .infinity,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Colors
                                                                      .white,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  pickEndTime(
                                                                      context);
                                                                },
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        _endEventTime ==
                                                                                null
                                                                            ? 'Select End Time'
                                                                            : 'End Time: ${_endEventTime.hour}:${_endEventTime.minute}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
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
                                    tag: "15",
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
                                                        Icons
                                                            .timer_off_outlined,
                                                        color: Colors.black),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "End Date-Time",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(
                                                                _eventDateEnd) +
                                                        " " +
                                                        _endEventTime.hour
                                                            .toString() +
                                                        ":" +
                                                        _endEventTime.minute
                                                            .toString(),
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return ' End Date-Time is Required';
                                                      }
                                                    },
                                                  ),
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
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue: _price,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return 'Price is Required';
                                                      }
                                                    },
                                                  ),
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
                                                            alignment: Alignment
                                                                .center,
                                                            height:
                                                                size.height /
                                                                    20,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: size.height / 20,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8,
                                                      horizontal: 30),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black12
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    initialValue:
                                                        _maxPartecipants,
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        new InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '',
                                                    ),
                                                    validator: (String? value) {
                                                      if (value!.isEmpty) {
                                                        return 'Maximum number of Partecipants is Required';
                                                      }
                                                    },
                                                  ),
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

                            if (_eventDateBegin.isAfter(_eventDateEnd)) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext builderContext) {
                                    _timer =
                                        Timer(Duration(milliseconds: 1200), () {
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
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        elevation: 20,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.8),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            'The Start Date-Time has to be before the End Date-Time!',
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
                              return;
                            }

                            await widget.databaseService!.createEventData(
                              _name,
                              _urlImage,
                              _description,
                              _address,
                              _placeName,
                              _typeOfPlace,
                              _eventType,
                              _eventDateBegin,
                              _eventDateEnd,
                              _maxPartecipants,
                              _price,
                              0,
                              localName,
                            );

                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext builderContext) {
                            //       _timer =
                            //           Timer(Duration(milliseconds: 1200), () {
                            //         Navigator.of(context).pop();
                            //       });

                            //       return Container(
                            //         margin: EdgeInsets.only(
                            //             bottom: 50, left: 12, right: 12),
                            //         decoration: BoxDecoration(
                            //           color: Colors.transparent,
                            //           borderRadius: BorderRadius.circular(40),
                            //         ),
                            //         child: AlertDialog(
                            //           shape: RoundedRectangleBorder(
                            //               borderRadius:
                            //                   BorderRadius.circular(30)),
                            //           elevation: 20,
                            //           backgroundColor:
                            //               Colors.white.withOpacity(0.8),
                            //           content: SingleChildScrollView(
                            //             child: Text(
                            //               'Your event has been created successfully!',
                            //               textAlign: TextAlign.center,
                            //             ),
                            //           ),
                            //         ),
                            //       );
                            //     }).then((val) {
                            //   if (_timer.isActive) {
                            //     _timer.cancel();
                            //   }
                            // });

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

class WideLayout extends StatefulWidget {
  final DatabaseService? databaseService;

  @override
  WideLayout({Key? key, this.databaseService}) : super(key: key);
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  ImagePicker image = ImagePicker();
  File? file;
  String _urlImage = '';
  String _price = '';

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    if (img!.path != null) {
      setState(() {
        file = File(img.path);
      });
    } else {
      return;
    }
  }

  uploadFile() async {
    var imageFile = await FirebaseStorage.instance
        .ref()
        .child(_name + "_" + _eventDateBegin.toString())
        .child("/" + _name + "_" + _eventDateBegin.toString() + ".jpg");
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
  String? localName;
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

  DateTime _eventDateBegin = DateTime.now(); //viene passata questa al db
  DateTime _eventDateEnd = DateTime.now(); //viene passata questa al db

  DateTime? _startEventDate;
  TimeOfDay _startEventTime = TimeOfDay.now();

  DateTime? _endEventDate;
  TimeOfDay _endEventTime = TimeOfDay.now();

  late Timer _timer;

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
      height: 100,
      width: 100,
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

  Widget _buildImage1() {
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
      height: 100,
      width: 100,
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

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  Future pickStartDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 2),
        selectableDayPredicate: _decideWhichDayToEnable,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF121B22), // header background color
                secondary: Colors.white,
                primaryVariant: Colors.white,
                secondaryVariant: Colors.white,
                onPrimary: Colors.white, // header text color
                onSurface: Colors.transparent,
                onBackground: Colors.white,
                onSecondary: Colors.white,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Color(0xFF121B22), // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newDate == null) return;

    setState(() {
      _startEventDate = newDate;
      _eventDateBegin = _startEventDate!;
    });
  }

  Future pickStartTime(BuildContext context) async {
    final initialTime = TimeOfDay.now();
    final newTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                primaryVariant: Colors.white, // header background color
                secondary: Color(0xFF121B22),
                onPrimary: Color(0xFF121B22),
                onSecondary: Colors.red,
                onBackground: Colors.white,
                secondaryVariant: Colors.red,
                surface: Color(0xFF121B22),
                onSurface: Colors.white,
                background: Colors.green,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newTime == null) return;

    setState(() {
      _startEventTime = newTime;
      _eventDateBegin = new DateTime(
          _eventDateBegin.year,
          _eventDateBegin.month,
          _eventDateBegin.day,
          _eventDateBegin.hour,
          _eventDateBegin.minute);
    });
  }

  Future pickEndDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 2),
        selectableDayPredicate: _decideWhichDayToEnable,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF121B22), // header background color
                secondary: Colors.white,
                primaryVariant: Colors.white,
                secondaryVariant: Colors.white,
                onPrimary: Colors.white, // header text color
                onSurface: Colors.transparent,
                onBackground: Colors.white,
                onSecondary: Colors.white,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Color(0xFF121B22), // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newDate == null) return;

    setState(() {
      _endEventDate = newDate;
      _eventDateEnd = _endEventDate!;
    });
  }

  Future pickEndTime(BuildContext context) async {
    final initialTime = TimeOfDay.now();
    final newTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                primaryVariant: Colors.white, // header background color
                secondary: Color(0xFF121B22),
                onPrimary: Color(0xFF121B22),
                onSecondary: Colors.red,
                onBackground: Colors.white,
                secondaryVariant: Colors.red,
                surface: Color(0xFF121B22),
                onSurface: Colors.white,
                background: Colors.green,
                // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  // button text color
                ),
              ),
            ),
            child: child!,
          );
        });
    if (newTime == null) return;

    setState(() {
      _endEventTime = newTime;
      _eventDateEnd = new DateTime(_eventDateEnd.year, _eventDateEnd.month,
          _eventDateEnd.day, _endEventTime.hour, _endEventTime.minute);
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
                          width: MediaQuery.of(context).size.width,
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
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              key: Key("list view"),
                              padding: const EdgeInsets.all(16),
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 16,
                                                    horizontal: 300,
                                                  ),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .event,
                                                                        color: Colors
                                                                            .black54,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        "Name of the Event",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black54,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              // const SizedBox(
                                                              //   height: 5,
                                                              // ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                                  textAlignVertical:
                                                                      TextAlignVertical
                                                                          .center,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  initialValue:
                                                                      _name,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .multiline,
                                                                  maxLines:
                                                                      null,
                                                                  cursorColor:
                                                                      Colors
                                                                          .black,
                                                                  validator:
                                                                      (String?
                                                                          value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Name is Required';
                                                                    }
                                                                  },
                                                                  decoration: InputDecoration(
                                                                      hintText:
                                                                          'Write the name...',
                                                                      border: InputBorder
                                                                          .none),
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      _name = value
                                                                          .trim();
                                                                      print(
                                                                          _name);
                                                                      print(
                                                                          localName);
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              _buildImage(),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            85,
                                                                        vertical:
                                                                            5),
                                                                child:
                                                                    ElevatedButton(
                                                                  key: Key(
                                                                      'upload image'),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    primary: Colors
                                                                        .white,
                                                                    onPrimary:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    uploadFile();
                                                                  },
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .upload,
                                                                            color:
                                                                                Colors.black),
                                                                        Text(
                                                                          "Upload Image",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: <Widget>[
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(Icons.event,
                                                                color: Colors
                                                                    .black),
                                                            SizedBox(width: 5),
                                                            Text(
                                                              "Name of the Event",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height:
                                                            size.height / 20,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 8,
                                                            horizontal: 30),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black12
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: _name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              new InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: '',
                                                          ),
                                                          validator:
                                                              (String? value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Name is Required';
                                                            }
                                                          },
                                                        ),
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
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 3,
                                                                  bottom: 3),
                                                          width: 30,
                                                          height: 3,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .black45
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      _buildImage1(),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                // //name + image

                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                      fontSize:
                                                                          16,
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
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                                  textAlignVertical:
                                                                      TextAlignVertical
                                                                          .center,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  initialValue:
                                                                      _description,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .multiline,
                                                                  maxLines:
                                                                      null,
                                                                  cursorColor:
                                                                      Colors
                                                                          .black,
                                                                  validator:
                                                                      (String?
                                                                          value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Descripion is Required';
                                                                    }
                                                                  },
                                                                  decoration: InputDecoration(
                                                                      hintText:
                                                                          'Write the description...',
                                                                      border: InputBorder
                                                                          .none),
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.description,
                                                          color: Colors.black,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          "Description of the Event",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue:
                                                            _description,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return 'Description is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),

                                // //place of the event
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                      fontSize:
                                                                          16,
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
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
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
                                                                        .databaseService!
                                                                        .getMyLocals(),
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<List<Local>>
                                                                            myLocals) {
                                                                      if (myLocals
                                                                          .hasError)
                                                                        return Container(
                                                                          child:
                                                                              Text('Some error may have occured'),
                                                                        );

                                                                      return DropdownButtonFormField2(
                                                                        // value:
                                                                        //     localName,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelStyle:
                                                                              TextStyle(fontWeight: FontWeight.w200),
                                                                          //Add isDense true and zero Padding.
                                                                          //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                          isDense:
                                                                              true,
                                                                          contentPadding:
                                                                              EdgeInsets.symmetric(horizontal: 8),
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
                                                                          color:
                                                                              Colors.black45,
                                                                        ),
                                                                        iconSize:
                                                                            30,
                                                                        buttonHeight:
                                                                            size.height /
                                                                                20,
                                                                        buttonPadding: const EdgeInsets.only(
                                                                            left:
                                                                                8,
                                                                            right:
                                                                                8),
                                                                        dropdownDecoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        items: myLocals.data !=
                                                                                null
                                                                            ? myLocals.data!
                                                                                .map((local) => DropdownMenuItem<String>(
                                                                                      child: Text(
                                                                                        local.localName,
                                                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                                                                      ),
                                                                                      value: local.localName,
                                                                                    ))
                                                                                .toList()
                                                                            : locals.map(buildMenuItems).toList(),
                                                                        validator:
                                                                            (value) {
                                                                          if (value ==
                                                                              null) {
                                                                            return 'Please select the Place of the Event.';
                                                                          }
                                                                        },
                                                                        onChanged:
                                                                            (value) =>
                                                                                setState(() => localName = value.toString()),
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.place,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Place of the Event",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: localName,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return 'Place of the Event is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                      fontSize:
                                                                          16,
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
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
                                                                child:
                                                                    DropdownButtonFormField2(
                                                                  value:
                                                                      _typeOfPlace,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelStyle: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w200),
                                                                    //Add isDense true and zero Padding.
                                                                    //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                    isDense:
                                                                        true,
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                    //Add more decoration as you want here
                                                                    //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                  ),
                                                                  isExpanded:
                                                                      true,
                                                                  hint:
                                                                      const Text(
                                                                    'Select the Type of Place...',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
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
                                                                  iconSize: 30,
                                                                  buttonHeight:
                                                                      size.height /
                                                                          20,
                                                                  buttonPadding:
                                                                      const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                  dropdownDecoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  items: TypeOfPlace.map((item) =>
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
                                                                              value.toString()),
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.flag,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Type of Place",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue:
                                                            _typeOfPlace,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return 'Type of place is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .security,
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
                                                                      fontSize:
                                                                          16,
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
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
                                                                child:
                                                                    DropdownButtonFormField2(
                                                                  value:
                                                                      _eventType,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelStyle: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w200),
                                                                    //Add isDense true and zero Padding.
                                                                    //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                    isDense:
                                                                        true,
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                    //Add more decoration as you want here
                                                                    //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                  ),
                                                                  isExpanded:
                                                                      true,
                                                                  hint:
                                                                      const Text(
                                                                    'Select the Privacy of the Event...',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
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
                                                                  iconSize: 30,
                                                                  buttonHeight:
                                                                      size.height /
                                                                          20,
                                                                  buttonPadding:
                                                                      const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                  dropdownDecoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  items: EventTypes.map((item) =>
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.security,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Privacy of the Event",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue:
                                                            _eventType,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return 'Privacy of the Event is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              5,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .timer_outlined,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      "Start Date-Time",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        25,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            85),
                                                                child: SizedBox(
                                                                  height: double
                                                                      .infinity,
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .white,
                                                                      onPrimary:
                                                                          Colors
                                                                              .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30.0),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      pickStartDate(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            _eventDateBegin == null
                                                                                ? 'Select End Date'
                                                                                : 'Start date: ${_eventDateBegin.day}/${_eventDateBegin.month}/${_eventDateBegin.year}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        25,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            85),
                                                                child: SizedBox(
                                                                  height: double
                                                                      .infinity,
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .white,
                                                                      onPrimary:
                                                                          Colors
                                                                              .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30.0),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      pickStartTime(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            _startEventTime == null
                                                                                ? 'Select End Time'
                                                                                : 'Start Time: ${_startEventTime.hour}:${_startEventTime.minute}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: Column(
                                                    children: <Widget>[
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .timer_outlined,
                                                                color: Colors
                                                                    .black),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Start Date-Time",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height:
                                                            size.height / 20,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            vertical: 8,
                                                            horizontal: 30),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black12
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          initialValue: DateFormat(
                                                                      'yyyy-MM-dd')
                                                                  .format(
                                                                      _eventDateBegin) +
                                                              " " +
                                                              _startEventTime
                                                                  .hour
                                                                  .toString() +
                                                              ":" +
                                                              _startEventTime
                                                                  .minute
                                                                  .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              new InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: '',
                                                          ),
                                                          validator:
                                                              (String? value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return ' Start Date-Time is Required';
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 3,
                                                                  bottom: 3),
                                                          width: 30,
                                                          height: 3,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .black45
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          HeroDialogRoute(
                                            builder: (context) => Center(
                                              child: Hero(
                                                tag: "15",
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              5,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .timer_outlined,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      "End Date-Time",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        25,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            85),
                                                                child: SizedBox(
                                                                  height: double
                                                                      .infinity,
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .white,
                                                                      onPrimary:
                                                                          Colors
                                                                              .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30.0),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      pickEndDate(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            _eventDateEnd == null
                                                                                ? 'Select End Date'
                                                                                : 'End Date: ${_eventDateEnd.day}/${_eventDateEnd.month}/${_eventDateEnd.year}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        25,
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            85),
                                                                child: SizedBox(
                                                                  height: double
                                                                      .infinity,
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .white,
                                                                      onPrimary:
                                                                          Colors
                                                                              .white,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30.0),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      pickEndTime(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            _endEventTime == null
                                                                                ? 'Select End Time'
                                                                                : 'End Time: ${_endEventTime.hour}:${_endEventTime.minute}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
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
                                        tag: "15",
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .timer_off_outlined,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "End Date-Time",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(
                                                                    _eventDateEnd) +
                                                            " " +
                                                            _endEventTime.hour
                                                                .toString() +
                                                            ":" +
                                                            _endEventTime.minute
                                                                .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return ' End Date-Time is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                      fontSize:
                                                                          16,
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
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                                  textAlignVertical:
                                                                      TextAlignVertical
                                                                          .center,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  initialValue:
                                                                      _price,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      _price = value
                                                                          .trim();
                                                                    });
                                                                  },
                                                                  cursorColor:
                                                                      Colors
                                                                          .black,
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
                                                                      hintText:
                                                                          'Write the Price (€)...',
                                                                      border: InputBorder
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.euro,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Price",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue: _price,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return 'Price is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 130),
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: GestureDetector(
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
                                                        BorderRadius.circular(
                                                            50),
                                                    color: Color(0xFF8596a0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              7,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .people,
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
                                                                      fontSize:
                                                                          16,
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
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height:
                                                                    size.height /
                                                                        20,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        30),
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
                                                                  textAlignVertical:
                                                                      TextAlignVertical
                                                                          .center,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  initialValue:
                                                                      _maxPartecipants,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      _maxPartecipants =
                                                                          value
                                                                              .trim();
                                                                    });
                                                                  },
                                                                  cursorColor:
                                                                      Colors
                                                                          .black,
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
                                                                      hintText:
                                                                          'Write the Number of Partecipants...',
                                                                      border: InputBorder
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.people,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Maximum of Partecipants",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: size.height / 20,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8,
                                                          horizontal: 30),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: TextFormField(
                                                        readOnly: true,
                                                        initialValue:
                                                            _maxPartecipants,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            new InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: '',
                                                        ),
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return 'Maximum number of Partecipants is Required';
                                                          }
                                                        },
                                                      ),
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black45
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
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
                        width: size.width - size.width / 2,
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

                            if (_eventDateBegin.isAfter(_eventDateEnd)) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext builderContext) {
                                    _timer =
                                        Timer(Duration(milliseconds: 1200), () {
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
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        elevation: 20,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.8),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            'The Start Date-Time has to be before the End Date-Time!',
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
                              return;
                            }

                            await widget.databaseService!.createEventData(
                              _name,
                              _urlImage,
                              _description,
                              _address,
                              _placeName,
                              _typeOfPlace,
                              _eventType,
                              _eventDateBegin,
                              _eventDateEnd,
                              _maxPartecipants,
                              _price,
                              0,
                              localName,
                            );

                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext builderContext) {
                            //       _timer =
                            //           Timer(Duration(milliseconds: 1200), () {
                            //         Navigator.of(context).pop();
                            //       });

                            //       return Container(
                            //         margin: EdgeInsets.only(
                            //             bottom: 50, left: 12, right: 12),
                            //         decoration: BoxDecoration(
                            //           color: Colors.transparent,
                            //           borderRadius: BorderRadius.circular(40),
                            //         ),
                            //         child: AlertDialog(
                            //           shape: RoundedRectangleBorder(
                            //               borderRadius:
                            //                   BorderRadius.circular(30)),
                            //           elevation: 20,
                            //           backgroundColor:
                            //               Colors.white.withOpacity(0.8),
                            //           content: SingleChildScrollView(
                            //             child: Text(
                            //               'Your event has been created successfully!',
                            //               textAlign: TextAlign.center,
                            //             ),
                            //           ),
                            //         ),
                            //       );
                            //     }).then((val) {
                            //   if (_timer.isActive) {
                            //     _timer.cancel();
                            //   }
                            // });

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
