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

  Future<dynamic> navigateToSettingsPage(String title) {
    return Navigator.of(context).push(MaterialPageRoute(
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
            onTap: () async {
              var businessName = await navigateToSettingsPage('Business Name');
              if(businessName != null){
                _vendorSettings.businessName = businessName;
              }
            },
          ),
          ListTile(
            title: Text('Business Description'),
            subtitle: Text('Untitled'),
            onTap: () async {
              var businessDesc = await navigateToSettingsPage('Business Description');
              if(businessDesc != null){
                _vendorSettings.businessDesc = businessDesc;
              }
            },
          ),
          ListTile(
            title: Text('FB Page URL'),
            subtitle: Text('Untitled'),
            onTap: () async {
              var fbURL = await navigateToSettingsPage('FB Page URL');
              if(fbURL != null){
                _vendorSettings.fbURL = fbURL;
              }
            },
          ),
          ListTile(
            title: Text('Location'),
            subtitle: Text('Lat: 0.000  |  Long: 0.000'),
            onTap: () async {
              var location = await navigateToSettingsPage('Location');
              if(location != null){
                _vendorSettings.location = location;
              }
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
                  var vendorSettings = _vendorSettings.toJson();
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
  final TextEditingController _txt1 = TextEditingController(text: 'sup');
  final TextEditingController _txt2 = TextEditingController(text: 'sup');

  ChangeVendorSettingPage(this._appBarTitle);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
          actions: <Widget>[
            FlatButton(
              child: Text('SAVE',style: TextStyle(color: Colors.white),),
              onPressed: () {
                dynamic returnVal = _appBarTitle.toString().toLowerCase() == 'location' ? {'latitude':_txt1.text, 'longitude':_txt2.text} : _txt1.text;
                Navigator.of(context).pop(returnVal);
              },
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: _appBarTitle.toString().toLowerCase() ==
                      'business description'
                  ? TextField(
                    controller: _txt1,
                      autofocus: true,
                      maxLines: 10,
                      decoration: InputDecoration(labelText: 'Enter a value'),
                    )
                  : _appBarTitle.toString().toLowerCase() == 'location'
                      ? Column(
                          children: <Widget>[
                            TextField(
                              controller: _txt1,
                              autofocus: true,
                              decoration:
                                  InputDecoration(labelText: 'Enter latitude'),
                            ),
                            TextField(
                              controller: _txt2,
                              autofocus: true,
                              decoration:
                                  InputDecoration(labelText: 'Enter longitude'),
                            )
                          ],
                        )
                      : TextField(
                        controller: _txt1,
                          autofocus: true,
                          decoration:
                              InputDecoration(labelText: 'Enter a value'),
                        ),
            )
          ],
        ));
  }
}
