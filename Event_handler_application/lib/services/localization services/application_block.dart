import 'dart:async';

import 'package:event_handler/services/localization%20services/geolocator_service.dart';
import 'package:event_handler/services/localization%20services/place_search.dart';
import 'package:event_handler/services/localization%20services/places_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/place.dart';

class ApplicationBlock with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();

  //variables
  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  StreamController<Place> selectedLocation =
      StreamController<Place>.broadcast();

  ApplicationBlock() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutoComplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    searchResults = null;
    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}