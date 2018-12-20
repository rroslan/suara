import 'package:flutter/material.dart';
import 'package:suara/screens/vendor_settings.dart';

class PhoneLoginScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: (){
            var route = MaterialPageRoute(
                builder: (BuildContext context)=>VendorSettingsScreen()
              );

              Navigator.of(context).push(route);
          },
          child: Text('Login'),
        ),
      ),
    );
  }

}