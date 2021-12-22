import 'package:event_handler/screens/home/place_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'place.dart';

class PlacesService {
  final key = 'AIzaSyCp-EXt7pBSEe6OySbG0CUImR3U_P4Y9Cg';

  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?key=$key&place_id=$placeId';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }
}
