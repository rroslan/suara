import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:suara/models/vendor_settings.dart';
import 'package:suara/screens/payment_topup.dart';

class VendorSettingsScreen extends StatefulWidget {
  final double _latitude;
  final double _longitude;

  VendorSettingsScreen(this._latitude, this._longitude);

  @override
  State<StatefulWidget> createState() => VendorSettingsScreenState();
}

class VendorSettingsScreenState extends State<VendorSettingsScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  var _ratingVal = 0.0;
  var _vendorSettings = new VendorSettings();
  //var c= widget._latitude;
  //var _latTxtController = TextEditingController(text: widget._latitude.toString());
  //var _longTxtController = TextEditingController(text: widget._longitude.toString());

  void navigateToSettingsPage(String title) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => ChangeVendorSettingPage(title)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Vendor Settings'),
        leading: Switch(
          value: false,
          activeColor: Colors.green,
          inactiveThumbColor: Colors.grey,
          onChanged: (val) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(val ? 'Online' : 'Offline'),
            ));
          },
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text('Available Balance'),
              IconButton(
                icon: Icon(Icons.payment),
                tooltip: 'Buy credit',
                onPressed: () {
                  var route = MaterialPageRoute(
                      builder: (BuildContext context) => PaymentTopUpScreen());

                  Navigator.of(context).push(route);
                },
              )
            ],
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Business Name'),
            subtitle: Text('Untitled'),
            onTap: () {
              navigateToSettingsPage('Business Name');
            },
          ),
          ListTile(
            title: Text('Business Description'),
            subtitle: Text('Untitled'),
            onTap: () {
              navigateToSettingsPage('Business Description');
            },
          ),
          ListTile(
            title: Text('FB Page URL'),
            subtitle: Text('Untitled'),
            onTap: () {
              navigateToSettingsPage('FB Page URL');
            },
          ),
          ListTile(
            title: Text('Location'),
            subtitle: Text('Lat: 0.000  |  Long: 0.000'),
            onTap: () {
              navigateToSettingsPage('Location');
            },
          ),
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Ratings'),
                StarRating(
                    starCount: 5,
                    size: 50.0,
                    rating: _ratingVal,
                    color: Colors.deepOrangeAccent,
                    onRatingChanged: (val) {
                      setState(() {
                        _ratingVal = val;
                      });
                    }),
              ],
            ),
          ),
          ListTile(
            title: RaisedButton(
              color: Colors.blue,
              onPressed: () {
                FirebaseAuth.instance.currentUser().then((onValue) {
                  print(onValue.uid);
                  var vendorSettings = _vendorSettings.toJson(
                      'Fiverr',
                      'A Company',
                      'https://www.facebook.com',
                      '37.4219983',
                      '-122.084');
                  Firestore.instance
                      .collection('vendorsettings')
                      .document(onValue.uid)
                      .setData(vendorSettings)
                      .then((e) {
                    print('done');
                  }).catchError((e) {
                    print(e);
                  });
                });
              },
              child: Text('Save'),
            ),
          )
        ],
      ),
    );
  }
}

class ChangeVendorSettingPage extends StatelessWidget {
  final _appBarTitle;

  ChangeVendorSettingPage(this._appBarTitle);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
      ),
      body: Center(
        child: Text('settings'),
      ),
    );
  }
}
