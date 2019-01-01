import 'dart:math';

import 'package:flutter/material.dart';
import 'package:suara/screens/vendor_settings.dart';

class PhoneLoginScreen extends StatelessWidget {
  final _random = new Random();
  final double _latitude;
  final double _longitude;

  PhoneLoginScreen(this._latitude,this._longitude);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: FittedBox(
          child: Column(
            children: <Widget>[
              Image.asset(
                'images/locked.png',
                width: 250.0,
                height: 250.0,
              ),
              RaisedButton(
                onPressed: () {
                  /*Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          VendorSettingsScreen(_latitude,_longitude)));*/
                  /*var min = 10000;
                  var max = 90000;
                  var generatedCode = min + (_random.nextInt(max-min));
                  print(generatedCode);*/
                  /*FirebaseAuth.instance.signInWithPhoneNumber(

                  )*/
                },
                child: Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
