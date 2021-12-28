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
  List<double> latList= [];
  List<double> longList= [];
  List<String> placeName = [];
  StreamSubscription? locationSubscription;
  StreamSubscription? eventsListener;

  @override
  void initState() { 
    final Stream<QuerySnapshot> events= DatabaseService(_authService.getCurrentUser()!.uid).getEvents();
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

  Marker createMarker(double latitude, double longitude, String placeName){
    log('latitude'+ latitude.toString());
    log('latitude'+ longitude.toString());
    log('latitude');

    return Marker(
    markerId: MarkerId(placeName),
    infoWindow: InfoWindow(title: placeName),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(latitude, longitude),);
  }

  @override
  Widget build(BuildContext context) {
    final applicationBlock = Provider.of<ApplicationBlock>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
      ),
      body: (applicationBlock.currentLocation == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(hintText: 'Search by City'),
                        onChanged: (value) =>
                            applicationBlock.searchPlaces(value),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        var place = await LocationService()
                            .getPlace(_searchController.text);
                        _goToPlace(place);
                      },
                      icon: Icon(Icons.search),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      height: 300,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
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
                    if (applicationBlock.searchResults != null &&
                        applicationBlock.searchResults!.length != 0)
                      Container(
                        height: 300.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.6),
                          backgroundBlendMode: BlendMode.darken,
                        ),
                      ),
                    if (applicationBlock.searchResults != null &&
                        applicationBlock.searchResults!.length != 0)
                      Container(
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
                      )
                  ],
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
    print(place.geometry!.location!.lat!.toString()+ " long: "+ place.geometry!.location!.lng!.toString());
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry!.location!.lat!, place.geometry!.location!.lng!),
            zoom: 14.0),
      ),
    );
  }
}
