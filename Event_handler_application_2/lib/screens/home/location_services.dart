import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final String key = 'AIzaSyDj7Scog6KZz7ujm8YMpG5wqgOY41g6jg4';

  Future<String> getPlacedId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    print('Input: ' + input);
    var response = await http.get(Uri.parse(url));
    print('Response: ' + response.toString());
    Map<String, dynamic> json = convert.jsonDecode(response.body);
    print('JSON: ' + json.toString());
    List<dynamic> data = json["dataKey"];
    print('JSON: ' + data.toString());
    var placeId = json['candidates'][0]['place_id'] as String;
    print(placeId);
    return placeId;
  }

  // Future<Map<String, dynamic>> getPlace(String input) async {
  //   final String url = 'https://maps.googleapis.com/maps/api/place/details/json?'
  // }
}
