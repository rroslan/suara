import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setLocation(double lat, double long) async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setDouble('lat', lat);
  pref.setDouble('long', long);
}

Future<dynamic> getLocation() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  var location = {
    'lat': '${pref.getDouble('lat')}',
    'long': '${pref.getDouble('long')}'
  };

  return location;
}

//commonly used for any error message that is given from firebase auth API
/*SnackBar errorSnackBar(
        GlobalKey<ScaffoldState> scaffoldKey, String errorMessage) =>
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white,
        onPressed: () {
          scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );*/