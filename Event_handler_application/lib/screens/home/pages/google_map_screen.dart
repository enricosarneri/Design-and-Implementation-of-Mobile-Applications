import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/map_completer/searchMapPlaceWidget.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/services/localization%20services/application_block.dart';
import 'package:event_handler/services/localization%20services/location_services.dart';
import 'package:event_handler/models/place.dart';
import 'package:event_handler/screens/home/side_filter.dart';
import 'package:event_handler/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:event_handler/services/auth.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/services.dart';
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  final setSlidingUpPanelFuncion;
  GoogleMapScreen({Key? key, this.setSlidingUpPanelFuncion}) : super(key: key);
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late BitmapDescriptor mapMarker;
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService(FirebaseAuth.instance);
  List<Marker> markers = [];
  StreamSubscription? locationSubscription;
  StreamSubscription? eventsListener;
  MapType _currentMapType = MapType.normal;
  PageController _pageController = new PageController();
  late bool _isSelected;
  late SfRangeValues _valuesPeople = new SfRangeValues(0, 100);
  late SfRangeValues _valuesPrices = new SfRangeValues(0, 100);
  late double _valuesKm = 500;
  late RangeValues _valuesPeopleR = new RangeValues(0, 100);
  late RangeValues _valuesPricesR = new RangeValues(0, 100);
  late RangeValues _valuesKmR = new RangeValues(0, 300);
  late List<PickerDateRange> _valuesDates = [];
  DateRangePickerController _dateRangePickerController =
      DateRangePickerController();

  late List<String> reportList = [
    'Cinema',
    'Theatre',
    'Restaurant',
    'Bar/Pub',
    'Disco',
    'Private Setting',
  ];
  List<String> selectedReportList = [];
  late List<int> _dynamicChipsColor = [
    0xFFff8a65,
    0xFF4fc3f7,
    0xFF9575cd,
    0xFF4db6ac,
    0xFF5cda65,
    0xFFff8a65,
  ];

  late List<EventLocation> _locations;
  late List<String> _filters;
  List<Event> _event_list = [];
  List<Event> listaDaFiltrare = [];

  @override
  void initState() {
    setCustomMarker();
    _isSelected = false;
    _filters = <String>[];
    _locations = <EventLocation>[
      const EventLocation('Cinema', 0xFFff8a65),
      const EventLocation('Theatre', 0xFF4fc3f7),
      const EventLocation('Restaurant', 0xFF9575cd),
      const EventLocation('Bar/Pub', 0xFF4db6ac),
      const EventLocation('Disco', 0xFF5cda65),
      const EventLocation('Private Setting', 0xFFff8a65),
    ];
    final Stream<List<Event>> eventsList = DatabaseService(
            _authService.getCurrentUser()!.uid, FirebaseFirestore.instance)
        .events;
    DatabaseService(
            _authService.getCurrentUser()!.uid, FirebaseFirestore.instance)
        .getCurrentUser();
    eventsListener = eventsList.listen((event) {
      for (var i = 0; i < event.length; i++) {
        setState(() {
          _event_list.add(event[i]);
        });
      }
    });
    listaDaFiltrare = _event_list;
    // eventsListener = eventsList.listen((event) {
    //   for (var i = 0; i < event.length; i++) {
    //     setState(() {
    //       markers.add(createMarker(
    //         event[i].latitude,
    //         event[i].longitude,
    //         event[i].placeName,
    //         event[i].date,
    //         event[i].description,
    //         event[i].eventType,
    //         event[i].managerId,
    //         event[i].maxPartecipants,
    //         event[i].name,
    //         event[i].eventId,
    //         event[i].partecipants,
    //         event[i].applicants,
    //         event[i].qrCodes,
    //         event[i].firstFreeQrCode,
    //       ));
    //     });
    //   }
    // });

    final applicationBlock =
        Provider.of<ApplicationBlock>(context, listen: false);
    locationSubscription =
        applicationBlock.selectedLocation.stream.listen((place) {
      if (place != null) {
        _goToPlace2(place);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    locationSubscription!.cancel();
    eventsListener!.cancel();
    super.dispose();
  }

  Marker createMarker(
      double latitude,
      double longitude,
      String placeName,
      String date,
      String description,
      String typeOfPlace,
      String eventType,
      String managerId,
      int maxPartecipants,
      double price,
      String name,
      String urlImage,
      String eventId,
      List<String> partecipants,
      List<String> applicants,
      List<String> qrcodes,
      int firstFreeQrCode) {
    Event event = Event(
        managerId,
        name,
        urlImage,
        description,
        latitude,
        longitude,
        placeName,
        typeOfPlace,
        eventType,
        date,
        maxPartecipants,
        price,
        eventId,
        partecipants,
        applicants,
        qrcodes,
        firstFreeQrCode);
    return Marker(
        markerId: MarkerId(placeName),
        infoWindow: InfoWindow(title: placeName, snippet: name),
        icon: mapMarker,
        position: LatLng(latitude, longitude),
        onTap: () {
          widget.setSlidingUpPanelFuncion(event);
        });
  }

  void setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 3,
        size: Size(5, 5),
      ),
      'assets/bap-2.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    final _scrollController = FixedExtentScrollController();

    Size size_screen = MediaQuery.of(context).size;

    final applicationBlock = Provider.of<ApplicationBlock>(context);

    void filterMarkers_people() {
      listaDaFiltrare = _event_list;
      print("lista da filtrare" + listaDaFiltrare.toString());
      List<Event> result = [];
      for (int i = 0; i < _event_list.length; i++) {
        double distance = Geolocator.distanceBetween(
            applicationBlock.currentLocation!.latitude,
            applicationBlock.currentLocation!.longitude,
            _event_list[i].latitude,
            _event_list[i].longitude);
        int distance_rounded = distance.round().toInt();
        print(applicationBlock.currentLocation!.latitude.toString() +
            "   " +
            applicationBlock.currentLocation!.longitude.toString());
        print(_event_list[i].latitude.toString() +
            "   " +
            _event_list[i].longitude.toString());
        print((distance_rounded / 1000).toString());
        print("Lunghezza lista date: " + _valuesDates.length.toString());
        int filtro_presente = 0;
        if (_filters.length == 0) {
          filtro_presente = 1;
        } else {
          for (int k = 0; k < _filters.length; k++) {
            if (_filters[k].compareTo(_event_list[i].typeOfPlace) == 0) {
              filtro_presente++;
            }
          }
        }
        if (_valuesDates.length == 0) {
          if ((_event_list[i].maxPartecipants <= _valuesPeopleR.end) &&
              (_event_list[i].partecipants.length >= _valuesPeopleR.start) &&
              (_valuesPricesR.start <= _event_list[i].price) &&
              (_valuesPricesR.end >= _event_list[i].price) &&
              ((distance_rounded / 1000) <= _valuesKmR.end) &&
              ((distance_rounded / 1000) >= _valuesKmR.start) &&
              filtro_presente != 0 &&
              _event_list[i].eventType == 'Public') {
            //&&   _event_list[i].eventType != "Private") {
            result.add(_event_list[i]);
          }
        } else {
          int exit = 0;
          for (int j = 0; j < _valuesDates.length; j++) {
            PickerDateRange temp = _valuesDates[j];

            if (DateTime.parse(_event_list[i].date)
                    .isAfter(temp.startDate!.subtract(Duration(days: 1))) &&
                DateTime.parse(_event_list[i].date)
                    .isBefore(temp.endDate!.add(Duration(days: 1)))) {
              exit++;
            }
          }
          if (exit != 0) {
            if ((_event_list[i].maxPartecipants <= _valuesPeopleR.end) &&
                (_event_list[i].partecipants.length >= _valuesPeopleR.start) &&
                (_valuesPricesR.start <= _event_list[i].price) &&
                (_valuesPricesR.end >= _event_list[i].price) &&
                ((distance_rounded / 1000) <= _valuesKmR.end) &&
                ((distance_rounded / 1000) >= _valuesKmR.start) &&
                filtro_presente != 0 &&
                _event_list[i].eventType == 'Public') {
              //&&   _event_list[i].eventType != "Private") {
              result.add(_event_list[i]);
            }
          }
        }
      }

      listaDaFiltrare = result;
      print("lista filtrata: " + listaDaFiltrare.toString());
    }

    return Scaffold(
      body: SlidingUpPanel(
        color: Color(0xFF121B22),
        minHeight: MediaQuery.of(context).size.height / 9,
        maxHeight: MediaQuery.of(context).size.height / 2.7,
        backdropEnabled: true,
        backdropOpacity: 0.6,
        boxShadow: const <BoxShadow>[
          BoxShadow(blurRadius: 30.0, color: Color.fromRGBO(0, 0, 0, 0.30))
        ],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        panel: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Container(
                height: size_screen.height * 0.23,
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          child: ListView(
                            padding: EdgeInsets.all(20),
                            itemExtent: size_screen.height * 0.10,
                            children: [
                              SizedBox(
                                height: (size_screen.height * 0.10),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: size_screen.width / 20),
                                  //decoration: BoxDecoration(color: Colors.red),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: (size_screen.height * 0.10) / 3,
                                        child: Container(
                                          //color: Colors.green,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.euro,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Prices (€)",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            //   color: Colors.yellow,

                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                thumbColor: Colors.black,
                                                activeTrackColor: Colors.black,
                                                activeTickMarkColor:
                                                    Colors.black,
                                                disabledInactiveTickMarkColor:
                                                    Colors.black,
                                                inactiveTickMarkColor:
                                                    Colors.black,
                                                trackHeight: 2,
                                                rangeThumbShape:
                                                    RoundRangeSliderThumbShape(
                                                        enabledThumbRadius: 10,
                                                        disabledThumbRadius: 3,
                                                        elevation: 8,
                                                        pressedElevation: 10),
                                                overlayShape:
                                                    RoundSliderOverlayShape(
                                                        overlayRadius: 25),
                                                minThumbSeparation: 10,
                                                rangeTrackShape:
                                                    RoundedRectRangeSliderTrackShape(),
                                                rangeTickMarkShape:
                                                    RoundRangeSliderTickMarkShape(
                                                        tickMarkRadius: 8),
                                                showValueIndicator:
                                                    ShowValueIndicator.always,
                                                rangeValueIndicatorShape:
                                                    PaddleRangeSliderValueIndicatorShape(),
                                                valueIndicatorColor:
                                                    Colors.black38,
                                                valueIndicatorTextStyle:
                                                    TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              child: RangeSlider(
                                                activeColor: Colors.white,
                                                inactiveColor:
                                                    Color(0xFF8596a0),
                                                values: _valuesPricesR,
                                                divisions: 20,
                                                min: 0,
                                                max: 100,
                                                labels: RangeLabels(
                                                  _valuesPricesR.start
                                                      .toInt()
                                                      .toString(),
                                                  _valuesPricesR.end
                                                      .toInt()
                                                      .toString(),
                                                ),
                                                onChanged:
                                                    (RangeValues values) {
                                                  setState(
                                                    () {
                                                      _valuesPricesR = values;
                                                    },
                                                  );
                                                },
                                                onChangeEnd:
                                                    (RangeValues values) {
                                                  setState(() {
                                                    filterMarkers_people();
                                                    print(_valuesPricesR.end);
                                                  });
                                                },
                                              ),
                                            )

                                            // child: SfRangeSlider(
                                            //   numberFormat: NumberFormat("\$"),
                                            //   activeColor: Color(0xFF78909C),
                                            //   stepSize: 1,
                                            //   min: 0.0,
                                            //   max: 100.0,
                                            //   values: _valuesPrices,
                                            //   interval: 20,
                                            //   showTicks: true,
                                            //   showLabels: true,
                                            //   enableTooltip: true,
                                            //   minorTicksPerInterval: 1,
                                            //   showDividers: true,
                                            //   onChanged: (SfRangeValues values) {
                                            //     setState(
                                            //       () {
                                            //         _valuesPrices = values;
                                            //       },
                                            //     );
                                            //   },
                                            //   onChangeEnd:
                                            //       (SfRangeValues values) {
                                            //     setState(() {
                                            //       print(_valuesPrices.end);
                                            //     });
                                            //   },
                                            // ),
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size_screen.height * 0.10,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: size_screen.width / 20),
                                  // decoration:
                                  //   BoxDecoration(color: Colors.green),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: (size_screen.height * 0.10) / 3,
                                        child: Container(
                                          //     color: Colors.green,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.people,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Number of Partecipants",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            // margin: EdgeInsets.symmetric(
                                            //     horizontal: 2),
                                            // //   color: Colors.yellow,

                                            // child: SfRangeSliderTheme(
                                            //   data: SfRangeSliderThemeData(
                                            //     activeDividerColor:
                                            //         Colors.transparent,
                                            //     activeTrackHeight: 4,
                                            //     inactiveTrackHeight: 2,
                                            //     inactiveDividerRadius: 4,
                                            //     activeDividerRadius: 5,
                                            //     thumbStrokeWidth: 100,
                                            //     inactiveDividerStrokeWidth: 15,
                                            //   ),
                                            //   child: SfRangeSlider(
                                            //     activeColor: Color(0xFF78909C),
                                            //     showDividers: true,
                                            //     stepSize: 5,
                                            //     min: 0.0,
                                            //     max: 100.0,
                                            //     values: _valuesPeople,
                                            //     interval: 20,
                                            //     showTicks: false,
                                            //     showLabels: true,
                                            //     enableTooltip: true,
                                            //     minorTicksPerInterval: 0,
                                            //     dragMode: SliderDragMode.onThumb,
                                            //     tooltipShape:
                                            //         SfPaddleTooltipShape(),
                                            //     onChanged:
                                            //         (SfRangeValues values) {
                                            //       setState(
                                            //         () {
                                            //           _valuesPeople = values;
                                            //         },
                                            //       );
                                            //     },
                                            //     onChangeEnd:
                                            //         (SfRangeValues values) {
                                            //       setState(() {
                                            //         print(_valuesPeople.end);
                                            //         filterMarkers_people();
                                            //       });
                                            //     },
                                            //   ),
                                            // ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            //   color: Colors.yellow,

                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                  activeTickMarkColor:
                                                      Colors.black,
                                                  disabledInactiveTickMarkColor:
                                                      Colors.black,
                                                  inactiveTickMarkColor:
                                                      Colors.black,
                                                  trackHeight: 2,
                                                  rangeThumbShape:
                                                      RoundRangeSliderThumbShape(
                                                          enabledThumbRadius:
                                                              10,
                                                          disabledThumbRadius:
                                                              3,
                                                          elevation: 8,
                                                          pressedElevation: 10),
                                                  overlayShape:
                                                      RoundSliderOverlayShape(
                                                          overlayRadius: 25),
                                                  minThumbSeparation: 10,
                                                  rangeTrackShape:
                                                      RoundedRectRangeSliderTrackShape(),
                                                  rangeTickMarkShape:
                                                      RoundRangeSliderTickMarkShape(
                                                          tickMarkRadius: 8),
                                                  showValueIndicator:
                                                      ShowValueIndicator.always,
                                                  rangeValueIndicatorShape:
                                                      PaddleRangeSliderValueIndicatorShape(),
                                                  valueIndicatorColor:
                                                      Colors.black38,
                                                  valueIndicatorTextStyle:
                                                      TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                              child: RangeSlider(
                                                activeColor: Colors.white,
                                                inactiveColor:
                                                    Color(0xFF8596a0),
                                                values: _valuesPeopleR,
                                                divisions: 100,
                                                min: 0,
                                                max: 100,
                                                labels: RangeLabels(
                                                  _valuesPeopleR.start
                                                      .toInt()
                                                      .toString(),
                                                  _valuesPeopleR.end
                                                      .toInt()
                                                      .toString(),
                                                ),
                                                onChanged:
                                                    (RangeValues values) {
                                                  setState(
                                                    () {
                                                      _valuesPeopleR = values;
                                                    },
                                                  );
                                                },
                                                onChangeEnd:
                                                    (RangeValues values) {
                                                  setState(() {
                                                    filterMarkers_people();
                                                    print(_valuesPeopleR.end);
                                                  });
                                                },
                                              ),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size_screen.height * 0.10,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: size_screen.width / 20),
                                  // decoration:
                                  //     BoxDecoration(color: Colors.green),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: (size_screen.height * 0.10) / 3,
                                        child: Container(
                                          //     color: Colors.green,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.transfer_within_a_station,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Distance (Km)",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            // margin: EdgeInsets.symmetric(
                                            //     horizontal: 2),
                                            // //   color: Colors.yellow,
                                            // child: SfSlider(
                                            //   activeColor: Color(0xFF78909C),
                                            //   showDividers: true,
                                            //   stepSize: 5,
                                            //   min: 0.0,
                                            //   max: 500.0,
                                            //   value: _valuesKm,
                                            //   interval: 50,
                                            //   showTicks: true,
                                            //   showLabels: true,
                                            //   enableTooltip: true,
                                            //   minorTicksPerInterval: 1,
                                            //   onChanged: (dynamic value) {
                                            //     setState(
                                            //       () {
                                            //         _valuesKm = value;
                                            //       },
                                            //     );
                                            //   },
                                            //   onChangeEnd: (dynamic value) {
                                            //     setState(() {
                                            //       filterMarkers_people();
                                            //     });
                                            //   },
                                            // ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            //   color: Colors.yellow,

                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                  activeTickMarkColor:
                                                      Colors.black,
                                                  disabledInactiveTickMarkColor:
                                                      Colors.black,
                                                  inactiveTickMarkColor:
                                                      Colors.black,
                                                  trackHeight: 2,
                                                  rangeThumbShape:
                                                      RoundRangeSliderThumbShape(
                                                          enabledThumbRadius:
                                                              10,
                                                          disabledThumbRadius:
                                                              3,
                                                          elevation: 8,
                                                          pressedElevation: 10),
                                                  overlayShape:
                                                      RoundSliderOverlayShape(
                                                          overlayRadius: 25),
                                                  minThumbSeparation: 10,
                                                  rangeTrackShape:
                                                      RoundedRectRangeSliderTrackShape(),
                                                  rangeTickMarkShape:
                                                      RoundRangeSliderTickMarkShape(
                                                          tickMarkRadius: 8),
                                                  showValueIndicator:
                                                      ShowValueIndicator.always,
                                                  rangeValueIndicatorShape:
                                                      PaddleRangeSliderValueIndicatorShape(),
                                                  valueIndicatorColor:
                                                      Colors.black38,
                                                  valueIndicatorTextStyle:
                                                      TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                              child: RangeSlider(
                                                inactiveColor:
                                                    Color(0xFF8596a0),
                                                activeColor: Colors.white,
                                                values: _valuesKmR,
                                                divisions: 60,
                                                min: 0,
                                                max: 300,
                                                labels: RangeLabels(
                                                  _valuesKmR.start
                                                      .toInt()
                                                      .toString(),
                                                  _valuesKmR.end
                                                      .toInt()
                                                      .toString(),
                                                ),
                                                onChanged:
                                                    (RangeValues values) {
                                                  setState(
                                                    () {
                                                      _valuesKmR = values;
                                                    },
                                                  );
                                                },
                                                onChangeEnd:
                                                    (RangeValues values) {
                                                  setState(() {
                                                    filterMarkers_people();
                                                    print(_valuesKmR.end);
                                                  });
                                                },
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5, right: 5, left: 5),
                          color: Colors.transparent,
                          child: Container(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  onSurface: Colors.white,
                                  primary: Colors.white,
                                ),
                              ),
                              child: SfDateRangePicker(
                                selectionTextStyle:
                                    TextStyle(color: Colors.white),
                                rangeTextStyle: TextStyle(color: Colors.white),
                                todayHighlightColor: Color(0xFF8596a0),
                                showNavigationArrow: false,
                                selectionRadius: 40,
                                headerHeight: 35,
                                backgroundColor: Colors.transparent,
                                selectionMode:
                                    DateRangePickerSelectionMode.multiRange,
                                selectionColor: Color(0xFF8596a0),
                                rangeSelectionColor: Color(0xFF8596a0),
                                endRangeSelectionColor: Color(0xFF8596a0),

                                startRangeSelectionColor: Color(0xFF8596a0),

                                onSelectionChanged:
                                    (DateRangePickerSelectionChangedArgs
                                        dateRangePickerSelectionChangedArgs) {
                                  setState(
                                    () {
                                      _valuesDates =
                                          dateRangePickerSelectionChangedArgs
                                              .value;
                                      int exit = 0;
                                      for (int i = 0;
                                          i < _valuesDates.length;
                                          i++) {
                                        PickerDateRange temp = _valuesDates[i];
                                        if (temp.endDate == null) {
                                          exit++;
                                        }
                                      }
                                      if (exit == 0) {
                                        filterMarkers_people();
                                      }
                                      print(_valuesDates);
                                      print(_valuesDates.length);
                                      ;
                                    },
                                  );
                                },
                                //showActionButtons: true,
                                onSubmit: (Object? val) {
                                  print(val);
                                },
                                controller: _dateRangePickerController,
                                onCancel: () {
                                  _dateRangePickerController.selectedRanges =
                                      null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                color: Colors.transparent,
                height: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(2),
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: 2,
                          effect: WormEffect(
                              type: WormType.thin,
                              dotHeight: 8,
                              dotWidth: 8,
                              dotColor: Color(0xFF8596a0),
                              activeDotColor: Colors.white),
                          onDotClicked: (index) =>
                              _pageController.animateToPage(index,
                                  duration: Duration(milliseconds: 3000),
                                  curve: Curves.bounceOut),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        collapsed: Container(
          decoration: BoxDecoration(
            color: Color(0xFF121B22),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Container(
            padding: EdgeInsets.only(top: 5),
            child: Align(
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        body: (applicationBlock.currentLocation == null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMap(
                      mapType: _currentMapType,
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                      indoorViewEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: {
                        for (var i = 0; i < listaDaFiltrare.length; i++)
                          createMarker(
                            listaDaFiltrare[i].latitude,
                            listaDaFiltrare[i].longitude,
                            listaDaFiltrare[i].placeName,
                            listaDaFiltrare[i].date,
                            listaDaFiltrare[i].description,
                            listaDaFiltrare[i].typeOfPlace,
                            listaDaFiltrare[i].eventType,
                            listaDaFiltrare[i].managerId,
                            listaDaFiltrare[i].maxPartecipants,
                            listaDaFiltrare[i].price,
                            listaDaFiltrare[i].name,
                            listaDaFiltrare[i].urlImage,
                            listaDaFiltrare[i].eventId,
                            listaDaFiltrare[i].partecipants,
                            listaDaFiltrare[i].applicants,
                            listaDaFiltrare[i].qrCodes,
                            listaDaFiltrare[i].firstFreeQrCode,
                          ),
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            applicationBlock.currentLocation!.latitude,
                            applicationBlock.currentLocation!.longitude),
                        zoom: 14,
                        bearing: 45,
                        tilt: 45,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        controller.setMapStyle('''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.government",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.medical",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.school",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]''');
                      },
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: size_screen.height / 6.3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    height: size_screen.height / 13,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FittedBox(
                        child: Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 4, left: 4),
                              child: FilterChip(
                                labelPadding: EdgeInsets.all(5.0),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade600,
                                  child: Text(
                                    _locations[0].location[0].toUpperCase(),
                                  ),
                                ),
                                label: Text(
                                  _locations[0].location,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey[60],
                                selected:
                                    _filters.contains(_locations[0].location),
                                backgroundColor: Color(_locations[0].color),
                                //padding: EdgeInsets.all(6),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _filters.add(_locations[0].location);
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    } else {
                                      _filters.removeWhere((String name) {
                                        return name == _locations[0].location;
                                      });
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    }
                                    filterMarkers_people();
                                  });
                                },
                                selectedColor: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 4, left: 4),
                              child: FilterChip(
                                labelPadding: EdgeInsets.all(5.0),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade600,
                                  child: Text(
                                    _locations[1].location[0].toUpperCase(),
                                  ),
                                ),
                                label: Text(
                                  _locations[1].location,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey[60],
                                selected:
                                    _filters.contains(_locations[1].location),
                                backgroundColor: Color(_locations[1].color),
                                //padding: EdgeInsets.all(6),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _filters.add(_locations[1].location);
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    } else {
                                      _filters.removeWhere((String name) {
                                        return name == _locations[1].location;
                                      });
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    }
                                    filterMarkers_people();
                                  });
                                },
                                selectedColor: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 4, left: 4),
                              child: FilterChip(
                                labelPadding: EdgeInsets.all(5.0),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade600,
                                  child: Text(
                                    _locations[2].location[0].toUpperCase(),
                                  ),
                                ),
                                label: Text(
                                  _locations[2].location,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey[60],
                                selected:
                                    _filters.contains(_locations[2].location),
                                backgroundColor: Color(_locations[2].color),
                                //padding: EdgeInsets.all(6),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _filters.add(_locations[2].location);
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    } else {
                                      _filters.removeWhere((String name) {
                                        return name == _locations[2].location;
                                      });
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    }
                                    filterMarkers_people();
                                  });
                                },
                                selectedColor: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 4, left: 4),
                              child: FilterChip(
                                labelPadding: EdgeInsets.all(5.0),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade600,
                                  child: Text(
                                    _locations[3].location[0].toUpperCase(),
                                  ),
                                ),
                                label: Text(
                                  _locations[3].location,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey[60],
                                selected:
                                    _filters.contains(_locations[3].location),
                                backgroundColor: Color(_locations[3].color),
                                //padding: EdgeInsets.all(6),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _filters.add(_locations[3].location);
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    } else {
                                      _filters.removeWhere((String name) {
                                        return name == _locations[3].location;
                                      });
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    }
                                    filterMarkers_people();
                                  });
                                },
                                selectedColor: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 4, left: 4),
                              child: FilterChip(
                                labelPadding: EdgeInsets.all(5.0),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade600,
                                  child: Text(
                                    _locations[4].location[0].toUpperCase(),
                                  ),
                                ),
                                label: Text(
                                  _locations[4].location,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey[60],
                                selected:
                                    _filters.contains(_locations[4].location),
                                backgroundColor: Color(_locations[4].color),
                                //padding: EdgeInsets.all(6),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _filters.add(_locations[4].location);
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    } else {
                                      _filters.removeWhere((String name) {
                                        return name == _locations[4].location;
                                      });
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    }
                                    filterMarkers_people();
                                  });
                                },
                                selectedColor: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, right: 4, left: 4),
                              child: FilterChip(
                                labelPadding: EdgeInsets.all(5.0),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.grey.shade600,
                                  child: Text(
                                    _locations[5].location[0].toUpperCase(),
                                  ),
                                ),
                                label: Text(
                                  _locations[5].location,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey[60],
                                selected:
                                    _filters.contains(_locations[5].location),
                                backgroundColor: Color(_locations[5].color),
                                //padding: EdgeInsets.all(6),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _filters.add(_locations[5].location);
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    } else {
                                      _filters.removeWhere((String name) {
                                        return name == _locations[5].location;
                                      });
                                      print("Lista Filtri: " +
                                          _filters.toString());
                                    }
                                    filterMarkers_people();
                                  });
                                },
                                selectedColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size_screen.height / 4.35,
                        left: size_screen.width * 0.85),
                    child: FloatingActionButton(
                      heroTag: 'toggle_map_type_button',
                      onPressed: _onToggleMapTypePressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      mini: true,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.layers,
                        size: 28.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  // if (applicationBlock.searchResults != null &&
                  //     applicationBlock.searchResults!.length != 0)
                  //   Padding(
                  //     padding: const EdgeInsets.only(
                  //         right: 12.0, left: 12.0, top: 70),
                  //     child: Container(
                  //       height: 300.0,
                  //       width: double.infinity,
                  //       decoration: BoxDecoration(
                  //         color: Colors.black.withOpacity(.6),
                  //         backgroundBlendMode: BlendMode.darken,
                  //         borderRadius: BorderRadius.circular(30),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.grey.withOpacity(0.5),
                  //             spreadRadius: 5,
                  //             blurRadius: 7,
                  //             offset: Offset(0, 3),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // if (applicationBlock.searchResults != null &&
                  //     applicationBlock.searchResults!.length != 0)
                  //   Padding(
                  //     padding: const EdgeInsets.only(
                  //         left: 12.0, right: 12.0, top: 70),
                  //     child: Container(
                  //       height: 300.0,
                  //       child: ListView.builder(
                  //         itemCount: applicationBlock.searchResults!.length,
                  //         itemBuilder: (context, index) {
                  //           return ListTile(
                  //             title: Text(
                  //               applicationBlock
                  //                   .searchResults![index].description!,
                  //               style: TextStyle(color: Colors.white),
                  //             ),
                  //             onTap: () {
                  //               applicationBlock.setSelectedLocation(
                  //                   applicationBlock
                  //                       .searchResults![index].placeId!);
                  //             },
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(left: 12, right: 12, top: 70),
                  //   child: Container(
                  //     height: 50,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.8),
                  //       borderRadius: BorderRadius.circular(50),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.grey.withOpacity(0.3),
                  //           spreadRadius: 5,
                  //           blurRadius: 7,
                  //           offset: Offset(0, 3),
                  //         ),
                  //       ],
                  //     ),
                  //     child: TextFormField(
                  //       textAlignVertical: TextAlignVertical.center,
                  //       cursorWidth: 2,
                  //       // cursorHeight: 16,
                  //       controller: _searchController,
                  //       textCapitalization: TextCapitalization.words,
                  //       decoration: InputDecoration(
                  //         contentPadding: EdgeInsets.zero,
                  //         hintText: 'Search by City...',
                  //         hintStyle: TextStyle(fontSize: 16),
                  //         labelStyle: TextStyle(fontSize: 16),
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(50),
                  //           borderSide: BorderSide(color: Colors.transparent),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(50),
                  //           borderSide: BorderSide(color: Colors.transparent),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(50),
                  //           borderSide: BorderSide(color: Colors.transparent),
                  //         ),
                  //         disabledBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(50),
                  //           borderSide: BorderSide(color: Colors.transparent),
                  //         ),
                  //         suffixIcon: Padding(
                  //           padding: const EdgeInsetsDirectional.only(end: 4.0),
                  //           child: IconButton(
                  //             onPressed: () async {
                  //               var place = await LocationService()
                  //                   .getPlace(_searchController.text);
                  //               _goToPlace(place);
                  //             },
                  //             icon: Icon(
                  //               Icons.search,
                  //               color: Colors.blueGrey,
                  //             ),
                  //           ),
                  //         ),
                  //         prefixIcon: Padding(
                  //           padding:
                  //               const EdgeInsetsDirectional.only(start: 4.0),
                  //           child: Icon(Icons.person),
                  //         ),
                  //       ),
                  //       cursorColor: Colors.black,
                  //       onChanged: (value) =>
                  //           applicationBlock.searchPlaces(value),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: size_screen.width * 0.81,
                        top: size_screen.height * 0.8),
                    child: FloatingActionButton(
                      onPressed: () async {
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: LatLng(
                                    applicationBlock.currentLocation!.latitude,
                                    applicationBlock
                                        .currentLocation!.longitude),
                                zoom: 14,
                                bearing: 45,
                                tilt: 45),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.my_location,
                        size: 25.0,
                        color: Colors.black54,
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: size_screen.height / 11,
                    left: MediaQuery.of(context).size.width * 0.04,
                    right: MediaQuery.of(context).size.width * 0.04,
                    child: SearchMapPlaceWidget(
                      apiKey: "AIzaSyCp-EXt7pBSEe6OySbG0CUImR3U_P4Y9Cg",
                      onSelected: (place) async {
                        final geolocation = await place.geolocation;
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                            CameraUpdate.newLatLng(geolocation.coordinates));
                        controller.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: geolocation.coordinates,
                              zoom: 14,
                              bearing: 45,
                              tilt: 45),
                        ));
                        // newLatLngBounds(
                        //     geolocation.bounds, 0));
                      },
                      onSearch: (place) async {},
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat, lng), zoom: 14, bearing: 45, tilt: 45),
      ),
    );
  }

  Future<void> _goToPlace2(Place place) async {
    print("go to place2 is called");
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry!.location!.lat!, place.geometry!.location!.lng!),
            zoom: 14.0,
            bearing: 45,
            tilt: 45),
      ),
    );
  }

  void _onToggleMapTypePressed() {
    final nextType = (_currentMapType == MapType.normal)
        ? MapType.satellite
        : MapType.normal;

    setState(() {
      _currentMapType = nextType;
    });
  }

  Iterable<Widget> get locationWidgets sync* {
    for (EventLocation location in _locations) {
      yield Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, right: 4, left: 4),
        child: FilterChip(
          labelPadding: EdgeInsets.all(5.0),
          avatar: CircleAvatar(
            backgroundColor: Colors.grey.shade600,
            child: Text(
              location.location[0].toUpperCase(),
            ),
          ),
          label: Text(
            location.location,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          elevation: 6.0,
          shadowColor: Colors.grey[60],
          selected: _filters.contains(location.location),
          backgroundColor: Color(location.color),
          //padding: EdgeInsets.all(6),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _filters.add(location.location);
                print("Lista Filtri: " + _filters.toString());
              } else {
                _filters.removeWhere((String name) {
                  return name == location.location;
                });
                print("Lista Filtri: " + _filters.toString());
              }
            });
          },
          selectedColor: Colors.grey,
        ),
      );
    }
  }
}

class EventLocation {
  const EventLocation(this.location, this.color);
  final String location;
  final int color;
}
