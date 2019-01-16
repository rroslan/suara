import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:suara/common/common.dart';
import 'package:suara/models/vendor_settings.dart';
import 'package:suara/screens/payment_topup.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:suara/screens/vendor_settings/category_settings_page.dart';
import 'package:suara/screens/vendor_settings/location_settings_page.dart';
import 'package:suara/screens/vendor_settings/normal_settings_page.dart';

class VendorSettingsScreen extends StatefulWidget {
  final double _latitude;
  final double _longitude;
  final String _loggedInUserId;

  VendorSettingsScreen(this._latitude, this._longitude, this._loggedInUserId);

  @override
  State<StatefulWidget> createState() => VendorSettingsScreenState();
}

class VendorSettingsScreenState extends State<VendorSettingsScreen> {
  bool isChangedFlag = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  VendorSettings _vendorSettings;
  final _categoriesList = <String>[
    'Delivery',
    'Learn',
    'Service',
    'Sell',
    'Rent'
  ];

  Future<dynamic> navigateToSettingsPage(
      String title, initialValue, bool isChecked) {
    return Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          if (title.toLowerCase() == 'business name' ||
              title.toLowerCase() == 'business description' ||
              title.toLowerCase() == 'fb page url' ||
              title.toLowerCase() == 'whatsapp no' ||
              title.toLowerCase() == 'phone no' ||
              title.toLowerCase() == 'sales contact') {
            return NormalSettingsPage(title, initialValue);
          } else if (title.toLowerCase() == 'default category') {
            return CategoriesSettingsPage(_vendorSettings.category);
          } else {
            return LocationSettingsPage(title, initialValue, isChecked);
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    _vendorSettings = VendorSettings(widget._loggedInUserId);
    setState(() {
      _vendorSettings.location = {
        'latitude': widget._latitude,
        'longitude': widget._longitude
      };
    });
    getLoggedInUserDetails();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String pathToRef = 'locations';
    Geofire.initialize(pathToRef);
  }

  void getLoggedInUserDetails() async {
    Firestore.instance
        .collection('vendorsettings')
        .where('uid', isEqualTo: _vendorSettings.uid)
        .snapshots()
        .listen((data) {
      if (data.documents.length > 0) {
        print(data.documents[0]['businessDesc']);
        var result = VendorSettings.fromJson(data.documents[0]);
        setState(() {
          _vendorSettings = result;
        });
        Geofire.initialize('locations/${_vendorSettings.category}');
      }
    });

    /*setState(() {
      _switchState = status == null ? false : status;
    });*/
  }

  Future<void> removeExistingGeofireEntries() async {
    for (var cat in _categoriesList) {
      await Geofire.initialize('locations/$cat');
      await Geofire.removeLocation(_vendorSettings.uid);
    }
  }

  void showProgressSnackBar(ScaffoldState scaffState, String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(message),
          )
        ],
      ),
      duration: Duration(seconds: 5),
    ));
  }

  Future<bool> showLocationNullValidationDialog() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text('Location not found'),
            content: Text(
                'The current location has not been set. Do you want to get the location and try again?'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ));

  Future<bool> showCategoryNullValidationDialog() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text('Category not found'),
            content: Text(
                'Default category has not been set. Do you want to set it and try again?'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ));

  Future<void> saveChanges() async {
    //before saving changes, checking if the vendor is online
    //if online: go offline, save changes and auto online
    //if offline: save changes and manual online
    print(_vendorSettings.uid);
    var vendorSettings = _vendorSettings.toJson();

    var tempOnlineStat = _vendorSettings.isOnline;

    if (tempOnlineStat) {
      await goOffline();
      setState(() {
        _vendorSettings.isOnline = false;
      });
    }

    showProgressSnackBar(_scaffoldKey.currentState, 'Saving changes...');
    await Firestore.instance
        .collection('vendorsettings')
        .document(_vendorSettings.uid)
        .setData(vendorSettings);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Save completed'),
    ));
    _scaffoldKey.currentState.hideCurrentSnackBar();
    isChangedFlag = false;
    print('done');

    if (tempOnlineStat) {
      goOnline();
      setState(() {
        _vendorSettings.isOnline = true;
      });
      await Firestore.instance
          .collection('vendorsettings')
          .document(_vendorSettings.uid)
          .updateData({'isOnline': _vendorSettings.isOnline});
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  Future<bool> willPopScope() {
    Future<bool> result;
    if (isChangedFlag) {
      result = showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Changes not saved'),
                content:
                    Text('There are unsaved changes. Do you want to save?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      return true;
                    },
                  ),
                  FlatButton(
                    child: Text('YES'),
                    onPressed: () async {
                      await saveChanges();
                      Navigator.of(context).pop(true);
                      return true;
                    },
                  )
                ],
              ));
    } else {
      result = Future.value(true);
    }

    return result;
  }

  void goOnline() async {
    //checking if location is null. if it is, asking if want to fetch the current location
    if (_vendorSettings.location['latitude'] == null ||
        _vendorSettings.location['longitude'] == null) {
      var result = await showLocationNullValidationDialog();

      //getting location
      if (result) {
        showProgressSnackBar(
            _scaffoldKey.currentState, 'Getting current location...');

        //getting result
        var currentLocation = await Location().getLocation();
        setState(() {
          _vendorSettings.location = {
            'latitude': currentLocation['latitude'],
            'longitude': currentLocation['longitude']
          };
        });
        isChangedFlag = true;
        _scaffoldKey.currentState.hideCurrentSnackBar();
      } else {
        return;
      }
    }

    //checking if we have a default category selected
    if (_vendorSettings.category == null) {
      var result = await showCategoryNullValidationDialog();

      if (result) {
        var category = await navigateToSettingsPage(
            'default category', _vendorSettings.category, false);
        if (category != null) {
          setState(() {
            _vendorSettings.category = category;
          });
          isChangedFlag = true;
        }
      } else {
        return;
      }
    }

    //before switching online, we need to save the user made changes to maintain the data consistency
    if (isChangedFlag) {
      var result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Changes not saved'),
                content:
                    Text('There are unsaved changes. Do you want to save?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('NO'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('YES'),
                    onPressed: () async {
                      showProgressSnackBar(
                          _scaffoldKey.currentState, 'Saving changes...');
                      await saveChanges();
                      _scaffoldKey.currentState.hideCurrentSnackBar();
                      Navigator.of(context).pop(true);
                    },
                  )
                ],
              ));

      if (result == false) {
        return;
      }
    }

    showProgressSnackBar(_scaffoldKey.currentState, 'Switching to online...');

    //removing existing geofire entries
    await removeExistingGeofireEntries();

    //re-initializing the user selected category
    await Geofire.initialize('locations/${_vendorSettings.category}');

    print('logged in user Id: ${_vendorSettings.uid}');
    bool response = await Geofire.setLocation(
        _vendorSettings.uid,
        _vendorSettings.location['latitude'],
        _vendorSettings.location['longitude']);
    print('geofire response: $response');
  }

  Future<void> goOffline() async {
    showProgressSnackBar(_scaffoldKey.currentState, 'Going offline...');
    //removing existing geofire entries
    await removeExistingGeofireEntries();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Vendor Settings'),
          leading: Switch(
            value: _vendorSettings.isOnline == null
                ? false
                : _vendorSettings.isOnline,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            onChanged: (val) async {
              if (val) {
                goOnline();
              } else {
                goOffline();
              }

              await Firestore.instance
                  .collection('vendorsettings')
                  .document(_vendorSettings.uid)
                  .updateData({'isOnline': val});

              //hide the progressive snack bar
              _scaffoldKey.currentState.hideCurrentSnackBar();

              setState(() {
                _vendorSettings.isOnline = val;
              });

              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(val ? 'Online' : 'Offline'),
              ));
            },
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                Text('${_vendorSettings.credits ?? initialCredit} MYR'),
                IconButton(
                  icon: Icon(Icons.payment),
                  tooltip: 'Buy credit',
                  onPressed: () {
                    var route = MaterialPageRoute(
                        builder: (BuildContext context) =>
                            PaymentTopUpScreen(_vendorSettings.salesContact));

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
                        : '',
                    false);
                if (businessName != null) {
                  setState(() {
                    _vendorSettings.businessName = businessName;
                  });
                  isChangedFlag = true;
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
                        : '',
                    false);
                if (businessDesc != null) {
                  setState(() {
                    _vendorSettings.businessDesc = businessDesc;
                  });
                  isChangedFlag = true;
                }
              },
            ),
            ListTile(
              title: Text('FB Page URL'),
              subtitle: Text(_vendorSettings.fbURL != null
                  ? _vendorSettings.fbURL
                  : 'Unspecified'),
              onTap: () async {
                var fbURL = await navigateToSettingsPage(
                    'FB Page URL',
                    _vendorSettings.fbURL != null ? _vendorSettings.fbURL : '',
                    false);
                if (fbURL != null) {
                  setState(() {
                    _vendorSettings.fbURL = fbURL;
                  });
                  isChangedFlag = true;
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
                        ? '${_vendorSettings.location['latitude']}|${_vendorSettings.location['longitude']}|${_vendorSettings.isLoc1Def}'
                        : null,
                    _vendorSettings.isLoc1Def);
                if (location != null) {
                  var tempLoc = {
                    'latitude': location['latitude'],
                    'longitude': location['longitude']
                  };
                  var isChecked = location['isChecked'];
                  setState(() {
                    _vendorSettings.location = tempLoc;
                    _vendorSettings.isLoc1Def = isChecked;
                  });
                  isChangedFlag = true;
                }
              },
              trailing: FittedBox(
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    _vendorSettings.isLoc1Def
                        ? Tooltip(
                            message: 'Default location',
                            child: Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          )
                        : Container(),
                    IconButton(
                      icon: Icon(Icons.pin_drop),
                      onPressed: () async {
                        var currentLocation = await Location().getLocation();
                        Clipboard.setData(ClipboardData(
                            text:
                                'Lat: ${currentLocation['latitude']} | Long: ${currentLocation['longitude']}'));

                        setState(() {
                          _vendorSettings.location = {
                            'latitude': currentLocation['latitude'],
                            'longitude': currentLocation['longitude']
                          };
                        });
                        isChangedFlag = true;
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Location 2'),
              subtitle: Text(_vendorSettings.location2 != null
                  ? 'Lat: ${_vendorSettings.location2['latitude']}  |  Long: ${_vendorSettings.location2['longitude']}'
                  : 'Lat: 0.0000  |  Long: 0.0000'),
              onTap: () async {
                var location = await navigateToSettingsPage(
                    'Location 2',
                    _vendorSettings.location2 != null
                        ? '${_vendorSettings.location2['latitude']}|${_vendorSettings.location2['longitude']}|${_vendorSettings.isLoc1Def}'
                        : null,
                    _vendorSettings.isLoc1Def);
                if (location != null) {
                  var tempLoc = {
                    'latitude': location['latitude'],
                    'longitude': location['longitude']
                  };
                  var isChecked = location['isChecked'];
                  setState(() {
                    _vendorSettings.location2 = tempLoc;
                    _vendorSettings.isLoc1Def = !isChecked;
                  });
                  isChangedFlag = true;
                }
              },
              trailing: FittedBox(
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    !_vendorSettings.isLoc1Def
                        ? Tooltip(
                            message: 'Default location',
                            child: Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          )
                        : Container(),
                    IconButton(
                      icon: Icon(Icons.pin_drop),
                      onPressed: () async {
                        var currentLocation = await Location().getLocation();
                        Clipboard.setData(ClipboardData(
                            text:
                                'Lat: ${currentLocation['latitude']} | Long: ${currentLocation['longitude']}'));

                        setState(() {
                          _vendorSettings.location2 = {
                            'latitude': currentLocation['latitude'],
                            'longitude': currentLocation['longitude']
                          };
                        });
                        isChangedFlag = true;
                      },
                    )
                  ],
                ),
              ),
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
                    _vendorSettings.whatsappNo != null
                        ? _vendorSettings.whatsappNo.isNotEmpty
                            ? _vendorSettings.whatsappNo
                            : ''
                        : '',
                    false);
                if (whatsappNo != null) {
                  setState(() {
                    _vendorSettings.whatsappNo = whatsappNo;
                  });
                  isChangedFlag = true;
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
                    _vendorSettings.phoneNo != null
                        ? _vendorSettings.phoneNo.isNotEmpty
                            ? _vendorSettings.phoneNo
                            : ''
                        : '',
                    false);
                if (phoneNo != null) {
                  setState(() {
                    _vendorSettings.phoneNo = phoneNo;
                  });
                  isChangedFlag = true;
                }
              },
            ),
            ListTile(
              title: Text('Default Category'),
              subtitle: Text(_vendorSettings.category == null
                  ? 'Unspecified'
                  : _vendorSettings.category.isEmpty
                      ? 'Unspecified'
                      : _vendorSettings.category),
              onTap: () async {
                var category = await navigateToSettingsPage(
                    'default category', _vendorSettings.category, false);
                if (category != null) {
                  setState(() {
                    _vendorSettings.category = category;
                  });
                  isChangedFlag = true;
                }
              },
            ),
            ListTile(
              title: Text('Sales Contact'),
              subtitle: Text(_vendorSettings.salesContact ?? 'Unspecified'),
              onTap: () async {
                var contact = await navigateToSettingsPage(
                    'Sales Contact', _vendorSettings.salesContact, false);
                if (contact != null) {
                  setState(() {
                    _vendorSettings.salesContact = contact;
                  });
                  isChangedFlag = true;
                }
              },
            ),
            ListTile(
              title: RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  saveChanges();
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
      onWillPop: willPopScope,
    );
  }
}
