import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:geocoder/geocoder.dart';

class LocationService {
  final String key = 'AIzaSyCp-EXt7pBSEe6OySbG0CUImR3U_P4Y9Cg';

  Future<String> getPlacedId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    print('Input: ' + input);
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlacedId(input);
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;
    return results;
  }

  Future<Coordinates> getCoordinatesByAddress(String address) async{
    var addresses= await Geocoder.local.findAddressesFromQuery(address);
    return Coordinates(addresses.first.coordinates.latitude, addresses.first.coordinates.longitude);
  }
}
