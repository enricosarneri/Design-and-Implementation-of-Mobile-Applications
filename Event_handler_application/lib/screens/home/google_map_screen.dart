import 'dart:async';

import 'package:event_handler/screens/home/application_block.dart';
import 'package:event_handler/screens/home/location_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'place.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  StreamSubscription? locationSubscription;

  void initState() {
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
    super.dispose();
  }

  static final Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: 'Google Plex'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(37.43296265331129, -122.08832357078792),
  );

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
                          //_kGooglePlexMarker,
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
}
