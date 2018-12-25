import 'package:flutter/material.dart';
import 'package:suara/screens/vendor_settings.dart';

class PhoneLoginScreen extends StatelessWidget {
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
              Image.asset('images/locked.png',width: 250.0,height: 250.0,),
              
              RaisedButton(
                onPressed: () {
                  var route = MaterialPageRoute(
                      builder: (BuildContext context) =>
                          VendorSettingsScreen());
                  Navigator.of(context).push(route);
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
