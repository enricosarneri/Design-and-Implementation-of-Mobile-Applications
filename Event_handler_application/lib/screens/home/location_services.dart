import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final String key = 'AIzaSyCp-EXt7pBSEe6OySbG0CUImR3U_P4Y9Cg';

  Future<String> getPlacedId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    print('Input: ' + input);
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;
    print(placeId);
    return placeId;
  }

  // Future<Map<String, dynamic>> getPlace(String input) async {
  //   final String url = 'https://maps.googleapis.com/maps/api/place/details/json?'
  // }
}
