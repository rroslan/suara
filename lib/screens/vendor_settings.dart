import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suara/models/vendor_settings.dart';
import 'package:suara/screens/payment_topup.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class VendorSettingsScreen extends StatefulWidget {
  final double _latitude;
  final double _longitude;
  final String _loggedInUserId;

  VendorSettingsScreen(this._latitude, this._longitude, this._loggedInUserId);

  @override
  State<StatefulWidget> createState() => VendorSettingsScreenState();
}

class VendorSettingsScreenState extends State<VendorSettingsScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  var _vendorSettings = new VendorSettings();
  //var c= widget._latitude;
  //var _latTxtController = TextEditingController(text: widget._latitude.toString());
  //var _longTxtController = TextEditingController(text: widget._longitude.toString());

  Future<dynamic> navigateToSettingsPage(String title, initialValue) {
    return Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) =>
            ChangeVendorSettingPage(title, initialValue)));
  }

  @override
  void initState() {
    super.initState();
    getLoggedInUserDetails();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String pathToRef = 'sites';
    Geofire.initialize(pathToRef);
  }

  void getLoggedInUserDetails() {
    Firestore.instance
        .collection('vendorsettings')
        .where('uid', isEqualTo: widget._loggedInUserId)
        .snapshots()
        .listen((data) {
      if (data.documents.length > 0) {
        print(data.documents[0]['businessDesc']);
        var result = VendorSettings.fromJson(data.documents[0]);
        setState(() {
          _vendorSettings = result;
        });
      }
    });
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
          onChanged: (val) async {
            print('logged in user Id: ${widget._loggedInUserId}');
            bool response = await Geofire.setLocation(
                widget._loggedInUserId, widget._latitude, widget._longitude);
            print('geofire response: $response');
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
            subtitle: Text(_vendorSettings.businessName != null
                ? _vendorSettings.businessName
                : 'Unspecified'),
            onTap: () async {
              var businessName = await navigateToSettingsPage(
                  'Business Name',
                  _vendorSettings.businessName != null
                      ? _vendorSettings.businessName
                      : '');
              if (businessName != null) {
                setState(() {
                  _vendorSettings.businessName = businessName;
                });
              }
            },
          ),
          ListTile(
            title: Text('Business Description'),
            subtitle: Text(_vendorSettings.businessDesc != null
                ? _vendorSettings.businessDesc
                : 'Unspecified'),
            onTap: () async {
              var businessDesc = await navigateToSettingsPage(
                  'Business Description',
                  _vendorSettings.businessDesc != null
                      ? _vendorSettings.businessDesc
                      : '');
              if (businessDesc != null) {
                setState(() {
                  _vendorSettings.businessDesc = businessDesc;
                });
              }
            },
          ),
          ListTile(
            title: Text('FB Page URL'),
            subtitle: Text(_vendorSettings.fbURL != null
                ? _vendorSettings.fbURL
                : 'Unspecified'),
            onTap: () async {
              var fbURL = await navigateToSettingsPage('FB Page URL',
                  _vendorSettings.fbURL != null ? _vendorSettings.fbURL : '');
              if (fbURL != null) {
                setState(() {
                  _vendorSettings.fbURL = fbURL;
                });
              }
            },
          ),
          ListTile(
            title: Text('Location'),
            subtitle: Text(_vendorSettings.location != null
                ? 'Lat: ${_vendorSettings.location['latitude']}  |  Long: ${_vendorSettings.location['longitude']}'
                : 'Lat: 0.0000  |  Long: 0.0000'),
            onTap: () async {
              var location = await navigateToSettingsPage(
                  'Location',
                  _vendorSettings.location != null
                      ? '${_vendorSettings.location['latitude']}|${_vendorSettings.location['longitude']}'
                      : null);
              if (location != null) {
                setState(() {
                  _vendorSettings.location = location;
                });
              }
            },
          ),
          ListTile(
            title: Text('Whatsapp Number'),
            subtitle: Text(_vendorSettings.whatsappNo != null
                ? _vendorSettings.whatsappNo.isNotEmpty
                    ? _vendorSettings.whatsappNo
                    : 'Unspecified'
                : 'Unspecified'),
            onTap: () async {
              var whatsappNo = await navigateToSettingsPage(
                  'Whatsapp No',
                  _vendorSettings.whatsappNo.isNotEmpty
                      ? _vendorSettings.whatsappNo
                      : '');
              if (whatsappNo != null) {
                setState(() {
                  _vendorSettings.whatsappNo = whatsappNo;
                });
              }
            },
          ),
          ListTile(
            title: Text('Phone Number'),
            subtitle: Text(_vendorSettings.phoneNo != null
                ? _vendorSettings.phoneNo.isNotEmpty
                    ? _vendorSettings.phoneNo
                    : 'Unspecified'
                : 'Unspecified'),
            onTap: () async {
              var phoneNo = await navigateToSettingsPage(
                  'Phone No',
                  _vendorSettings.phoneNo.isNotEmpty
                      ? _vendorSettings.phoneNo
                      : '');
              if (phoneNo != null) {
                setState(() {
                  _vendorSettings.phoneNo = phoneNo;
                });
              }
            },
          ),
          ListTile(
            title: Text('Open in Waze'),
            onTap: () {
              AppAvailability.checkAvailability('com.waze').then((appInfo) {
                AppAvailability.launchApp('com.waze');
              }).catchError((error) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(error),
                ));
              });
            },
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
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ChangeVendorSettingPage extends StatelessWidget {
  final String _appBarTitle;
  final String _initialValue;
  final TextEditingController _txt1 = TextEditingController(text: '');
  final TextEditingController _txt2 = TextEditingController(text: '');

  ChangeVendorSettingPage(this._appBarTitle, this._initialValue);

  @override
  Widget build(BuildContext context) {
    _txt1.text = _appBarTitle.toString() == 'Location'
        ? _initialValue != null ? _initialValue.split('|')[0] : ''
        : _initialValue;
    _txt2.text = _appBarTitle.toString() == 'Location'
        ? _initialValue != null ? _initialValue.split('|')[1] : ''
        : null;

    return Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                dynamic returnVal = _appBarTitle.toLowerCase() == 'location'
                    ? {'latitude': _txt1.text, 'longitude': _txt2.text}
                    : _txt1.text;
                Navigator.of(context).pop(returnVal);
              },
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: _appBarTitle.toLowerCase() == 'business description'
                  ? TextField(
                      controller: _txt1,
                      autofocus: true,
                      maxLines: 10,
                      decoration: InputDecoration(labelText: 'Enter a value'),
                    )
                  : _appBarTitle.toLowerCase() == 'location'
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
