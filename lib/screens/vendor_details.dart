import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suara/models/vendor_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class VendorDetailsScreen extends StatefulWidget {
  final _loggedInUserId;

  VendorDetailsScreen(this._loggedInUserId);

  @override
  State<StatefulWidget> createState() => VendorDetailsScreenState();
}

class VendorDetailsScreenState extends State<VendorDetailsScreen> {
  static const platform = const MethodChannel('saura.biz/deeplinks');
  VendorSettings _vendorDetails;

  @override
  void initState() {
    super.initState();
    var subscription = Firestore.instance
        .collection('vendorsettings')
        .document(widget._loggedInUserId)
        .snapshots()
        .listen((data) => {});

    subscription.onData((data) {
      setState(() {
        _vendorDetails = VendorSettings.fromJson(data.data);
      });
      subscription.cancel();
    });
  }

  void makePhoneCall() async {
    var url = 'tel:${_vendorDetails.phoneNo}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  void sendSMS() async {
    var url = 'sms:${_vendorDetails.phoneNo}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  void openWhatsapp() async {
    var url =
        'https://api.whatsapp.com/send?phone=${_vendorDetails.whatsappNo}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  void openFacebook() async {
    var url = 'https://www.facebook.com/${_vendorDetails.fbURL}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  Future<dynamic> openWazeLink() async {
    try {
      var result = await platform.invokeMethod('openWazeClientApp', {
        'latitude': '${_vendorDetails.location['latitude']}',
        'longitude': '${_vendorDetails.location['longitude']}'
      });
      print(result);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    var businessName = _vendorDetails != null
        ? _vendorDetails.businessName == null
            ? 'Unspecified'
            : _vendorDetails.businessName
        : 'Please wait...';
    var businessDesc = _vendorDetails != null
        ? _vendorDetails.businessDesc == null
            ? 'Unspecified'
            : _vendorDetails.businessDesc
        : 'Please wait...';
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Details'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
                title: Text(
                  'Business Details',
                  style: TextStyle(fontSize: 20.0),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    Container(
                      child: Text(
                        'Name',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Container(
                      child: Text(businessName),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    Container(
                      child: Text(
                        'Description',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Container(
                      child: Text(businessDesc),
                    )
                  ],
                )),
          ),
          Card(
            child: ListTile(
                title: Text(
                  'Social Contacts',
                  style: TextStyle(fontSize: 20.0),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      title: Text('Call'),
                      subtitle: Text('Make a phone call'),
                      trailing: Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      onTap: () {
                        if (_vendorDetails.phoneNo != null) {
                          makePhoneCall();
                        }
                      },
                    ),
                    ListTile(
                      title: Text('SMS'),
                      subtitle: Text('Send a message'),
                      trailing: Icon(
                        Icons.sms,
                        color: Colors.black,
                      ),
                      onTap: () {
                        if (_vendorDetails.phoneNo != null) {
                          sendSMS();
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Whatsapp'),
                      subtitle: Text('Open up'),
                      trailing: Image.asset(
                        'images/whatsapp.png',
                        scale: 1.2,
                      ),
                      onTap: () {
                        if (_vendorDetails.whatsappNo != null) {
                          openWhatsapp();
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Facebook'),
                      subtitle: Text('Look up'),
                      trailing: Image.asset(
                        'images/facebook.png',
                        scale: 1.2,
                      ),
                      onTap: () {
                        if (_vendorDetails.fbURL != null) {
                          openFacebook();
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Waze'),
                      subtitle: Text('Navigate'),
                      trailing: Image.asset(
                        'images/waze.png',
                        scale: 1.2,
                      ),
                      onTap: () {
                        if (_vendorDetails.location != null) {
                          openWazeLink().then((result) {
                            print(result);
                          });
                        }
                      },
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
