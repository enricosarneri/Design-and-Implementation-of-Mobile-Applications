import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/services/localization%20services/application_block.dart';
import 'package:event_handler/services/localization%20services/location_services.dart';
import 'package:event_handler/models/place.dart';
import 'package:event_handler/screens/home/side_filter.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:event_handler/services/auth.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  final setSlidingUpPanelFuncion;
  GoogleMapScreen({Key? key, this.setSlidingUpPanelFuncion}) : super(key: key);
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  List<Marker> markers = [];
  StreamSubscription? locationSubscription;
  StreamSubscription? eventsListener;
  MapType _currentMapType = MapType.normal;
  PageController _pageController = new PageController();

  late bool _isSelected;

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

  @override
  void initState() {
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
    final Stream<List<Event>> eventsList =
        DatabaseService(_authService.getCurrentUser()!.uid).events;
    DatabaseService(_authService.getCurrentUser()!.uid).getCurrentUser();
    eventsListener = eventsList.listen((event) {
      for (var i = 0; i < event.length; i++) {
        setState(() {
          markers.add(createMarker(
              event[i].latitude,
              event[i].longitude,
              event[i].placeName,
              event[i].date,
              event[i].description,
              event[i].eventType,
              event[i].managerId,
              event[i].maxPartecipants,
              event[i].name));
        });
      }
    });

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
      String eventType,
      String managerId,
      int maxPartecipants,
      String name) {
    Event event = Event(managerId, name, description, latitude, longitude,
        placeName, eventType, date, maxPartecipants);
    return Marker(
        markerId: MarkerId(placeName),
        infoWindow: InfoWindow(title: placeName),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(latitude, longitude),
        onTap: () {
          widget.setSlidingUpPanelFuncion(event);
        });
  }

  @override
  Widget build(BuildContext context) {
    final applicationBlock = Provider.of<ApplicationBlock>(context);
    return Scaffold(
      body: DraggableBottomSheet(
        backgroundWidget: Scaffold(
          body: (applicationBlock.currentLocation == null)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    Container(
                      child: GoogleMap(
                        mapType: _currentMapType,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        indoorViewEnabled: true,
                        myLocationButtonEnabled: false,
                        markers: {
                          for (var i = 0; i < markers.length; i++) markers[i]
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              applicationBlock.currentLocation!.latitude,
                              applicationBlock.currentLocation!.longitude),
                          zoom: 14,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 130, left: 330),
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
                    if (applicationBlock.searchResults != null &&
                        applicationBlock.searchResults!.length != 0)
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 12.0, left: 12.0, top: 70),
                        child: Container(
                          height: 300.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.6),
                            backgroundBlendMode: BlendMode.darken,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (applicationBlock.searchResults != null &&
                        applicationBlock.searchResults!.length != 0)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, top: 70),
                        child: Container(
                          height: 300.0,
                          child: ListView.builder(
                            itemCount: applicationBlock.searchResults!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  applicationBlock
                                      .searchResults![index].description!,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  applicationBlock.setSelectedLocation(
                                      applicationBlock
                                          .searchResults![index].placeId!);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 70),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorWidth: 2,
                          // cursorHeight: 16,
                          controller: _searchController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search by City...',
                            hintStyle: TextStyle(fontSize: 16),
                            labelStyle: TextStyle(fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            suffixIcon: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 4.0),
                              child: IconButton(
                                onPressed: () async {
                                  var place = await LocationService()
                                      .getPlace(_searchController.text);
                                  _goToPlace(place);
                                },
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 4.0),
                              child: Icon(Icons.person),
                            ),
                          ),
                          cursorColor: Colors.black,
                          onChanged: (value) =>
                              applicationBlock.searchPlaces(value),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 315, top: 630),
                      child: FloatingActionButton(
                        onPressed: () async {
                          final GoogleMapController controller =
                              await _controller.future;
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                  target: LatLng(
                                      applicationBlock
                                          .currentLocation!.latitude,
                                      applicationBlock
                                          .currentLocation!.longitude),
                                  zoom: 14),
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
                  ],
                ),
        ),
        expandedChild: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            color: Colors.black54,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: 27,
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 2, left: 2),
                height: MediaQuery.of(context).size.height * 0.35 - 68 - 45,
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      children: [
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(
                            right: 8.0,
                            left: 8.0,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                color: Colors.transparent,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: rowChips(),
                                ),
                              ),
                              Container(
                                color: Colors.yellow,
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              'Page2',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 20,
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
                              dotHeight: 10,
                              dotWidth: 10,
                              dotColor: Colors.black38,
                              activeDotColor: Colors.black),
                          onDotClicked: (index) =>
                              _pageController.animateToPage(index,
                                  duration: Duration(milliseconds: 500),
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
        previewChild: Container(
          padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            color: Colors.black54,
          ),
          child: Column(
            children: [
              Container(
                height: 3.5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ],
          ),
        ),
        minExtent: 80,
        expansionExtent: 150,
        maxExtent: MediaQuery.of(context).size.height * 0.35,
      ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
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
            zoom: 14.0),
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

  rowChips() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: <Widget>[
          chipForRow('Cinema', Color(0xFFff8a65)),
          chipForRow('Theatre', Color(0xFF4fc3f7)),
          chipForRow('Bar/Pub', Color(0xFF9575cd)),
          chipForRow('Restaurant', Color(0xFF4db6ac)),
          chipForRow('Disco', Color(0xFF5cda65)),
          chipForRow('Private Location', Color(0xFFff8a65)),
        ],
      ),
    );
  }

  Widget chipForRow(String label, Color color) {
    return FittedBox(
      child: Container(
        margin: EdgeInsets.only(right: 8.0, left: 8.0),
        child: Chip(
          labelPadding: EdgeInsets.all(5.0),
          avatar: CircleAvatar(
            backgroundColor: Colors.grey.shade600,
            child: Text('AB'),
          ),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: color,
          elevation: 6.0,
          shadowColor: Colors.grey[60],
          padding: EdgeInsets.all(6),
        ),
      ),
    );
  }
}

class EventLocation {
  const EventLocation(this.location, this.color);
  final String location;
  final int color;
}
