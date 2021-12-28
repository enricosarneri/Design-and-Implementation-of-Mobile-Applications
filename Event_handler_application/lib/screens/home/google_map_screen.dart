import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/home/services/application_block.dart';
import 'package:event_handler/screens/home/services/location_services.dart';
import 'package:event_handler/screens/home/services/place.dart';
import 'package:event_handler/services/database.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:event_handler/services/auth.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  List<double> latList = [];
  List<double> longList = [];
  List<String> placeName = [];
  StreamSubscription? locationSubscription;
  StreamSubscription? eventsListener;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    final Stream<QuerySnapshot> events =
        DatabaseService(_authService.getCurrentUser()!.uid).getEvents();
    eventsListener = events.listen((event) {
      for (var i = 0; i < event.size; i++) {
        latList.add(double.parse(event.docs[i]['latitude']));
        longList.add(double.parse(event.docs[i]['longitude']));
        placeName.add(event.docs[i]['placeName']);
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
    final applicationBlock =
        Provider.of<ApplicationBlock>(context, listen: false);
    applicationBlock.dispose();
    locationSubscription!.cancel();
    eventsListener!.cancel();
    super.dispose();
  }

  Marker createMarker(double latitude, double longitude, String placeName) {
    log('latitude' + latitude.toString());
    log('latitude' + longitude.toString());
    log('latitude');

    return Marker(
      markerId: MarkerId(placeName),
      infoWindow: InfoWindow(title: placeName),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(latitude, longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicationBlock = Provider.of<ApplicationBlock>(context);
    return Scaffold(
      body: (applicationBlock.currentLocation == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Expanded(
                  child: Container(
                    child: GoogleMap(
                      mapType: _currentMapType,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      padding: EdgeInsets.only(top: 500.0),
                      indoorViewEnabled: true,
                      markers: {
                        for (var i = 0; i < latList.length; i++)
                          createMarker(latList[i], longList[i], placeName[i])
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
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150, left: 340),
                  child: FloatingActionButton(
                    heroTag: 'toggle_map_type_button',
                    onPressed: _onToggleMapTypePressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    mini: true,
                    backgroundColor: Colors.teal[300],
                    child: const Icon(Icons.layers, size: 28.0),
                  ),
                ),
                if (applicationBlock.searchResults != null &&
                    applicationBlock.searchResults!.length != 0)
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 12.0, left: 12.0, top: 70),
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
                    padding:
                        const EdgeInsets.only(left: 12.0, right: 12.0, top: 70),
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
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 70),
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
                      cursorHeight: 25,
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
                        suffixIcon: IconButton(
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
                        prefixIcon: Icon(Icons.person),
                      ),
                      cursorColor: Colors.black,
                      onChanged: (value) =>
                          applicationBlock.searchPlaces(value),
                    ),
                  ),
                ),
              ],
            ),

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
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
    print(place.geometry!.location!.lat!.toString() +
        " long: " +
        place.geometry!.location!.lng!.toString());
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
}
