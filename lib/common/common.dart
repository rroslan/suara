
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setLocation(double lat, double long) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setDouble('lat', lat);
  pref.setDouble('long', long);
}

Future<dynamic> getLocation() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  var location = {
    'lat': '${pref.getDouble('lat')}',
    'long': '${pref.getDouble('long')}'
  };

  return location;
}

final int initialCredit = 3;

final String kPlacesAPIKey = 'AIzaSyCxfwz1Bo3KmijBjPqDZkRNzH8Qza3d7b8';
final double bottomNavBarIconSize = 25.0;