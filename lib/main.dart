import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:suara/common/common.dart';
import 'package:suara/common/keys.dart';
import 'package:suara/models/vendor_settings.dart';
import 'package:suara/models/vendors.dart';
import 'package:suara/screens/vendor_details.dart';
import 'package:location/location.dart' as loco;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suara/screens/vendor_settings.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suara',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(
              snapshot.data,
              title: 'Suara',
            );
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FirebaseUser _loggedInUser;

  MyHomePage(this._loggedInUser, {Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class LoginPage extends StatelessWidget {
  void initiateGoogleLogin(BuildContext context) {
    GoogleSignIn _googleSignIn = GoogleSignIn();

    _googleSignIn.signIn().then((result) {
      result.authentication.then((googleKey) {
        FirebaseAuth.instance
            .signInWithGoogle(
                idToken: googleKey.idToken, accessToken: googleKey.accessToken)
            .then((signedInUser) {
          print('signed in');
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MyHomePage(signedInUser)));
        });
      }).catchError((error) {
        print(error.message);
      });
    }).catchError((error) {
      print(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: Image.asset(
              'images/login_background.png',
              alignment: Alignment.bottomRight,
              color: Colors.green,
            ),
          ),
          Center(
            child: FittedBox(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'images/app_logo.png',
                    width: 290.0,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                  ),
                  Container(
                    width: 150.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 5.0)),
                    child: InkWell(
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: Center(
                          child: Text(
                            'Login with Google',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onTap: () {
                        initiateGoogleLogin(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  var _currentLocation = <String, double>{};
  var location = new loco.Location();
  var businessDetails = <Vendors>[];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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

  Future<void> manipulateDataTable() async {
    if (_currentLocation.values.length == 0) {
      var result = await showLocationNullValidationDialog();
      if (result) {
        _currentLocation = await location.getLocation();
      } else {
        return;
      }
    }

    var path = _currentIndex == 0
        ? 'Delivery'
        : _currentIndex == 1
            ? 'Learn'
            : _currentIndex == 2
                ? "Service"
                : _currentIndex == 3
                    ? 'Sell'
                    : _currentIndex == 4 ? 'Rent' : 'Jobs';
    var latitude = _currentLocation['latitude'];
    var longitude = _currentLocation['longitude'];
    var radiusInKm = _currentIndex == 0
        ? 20.0
        : _currentIndex == 1.0
            ? 700.0
            : _currentIndex == 2
                ? 30.0
                : _currentIndex == 3 ? 10.0 : _currentIndex == 4 ? 10.0 : 50.0;

    await Geofire.initialize('locations/$path');

    var listOfKeys =
        await Geofire.queryAtLocation(latitude, longitude, radiusInKm);

    final listOfRefs = listOfKeys
        .map((key) => Firestore.instance.document('vendorsettings/$key'))
        .toList();

    if (mounted) {
      setState(() {
        businessDetails = [];
      });
    }

    for (var ref in listOfRefs) {
      var subscription = ref.snapshots().listen((data) {});

      subscription.onData((data) {
        if (data.data != null) {
          var vendor = VendorSettings.fromJson(data.data);
          final double vendorLat = vendor.isLoc1Def
              ? vendor.location['latitude']
              : vendor.location2['latitude'];
          final double vendorLon = vendor.isLoc1Def
              ? vendor.location['longitude']
              : vendor.location2['longitude'];

          final distance = new Distance();
          final meters = distance.as(
              LengthUnit.Meter,
              LatLng(vendorLat, vendorLon),
              LatLng(
                  _currentLocation['latitude'], _currentLocation['longitude']));
          final distanceTxt =
              meters >= 1000 ? '${(meters / 1000.0)}  km' : '$meters m';
          setState(() {
            businessDetails.add(Vendors(vendor.uid, vendor.businessName,
                vendor.businessDesc, distanceTxt));
          });
        }
        subscription.cancel();
      });
    }

    print(listOfKeys.length);
  }

  @override
  void initState() {
    super.initState();

    //when the widget is build, then runs this callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _currentLocation = await location.getLocation();
      Clipboard.setData(ClipboardData(
          text:
              '${_currentLocation['latitude']},${_currentLocation['longitude']}'));
      _refreshIndicatorKey.currentState.show();
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _locationSearchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (tappedIndex) {
          setState(() {
            _currentIndex = tappedIndex;
          });
          _refreshIndicatorKey.currentState.show();
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                'images/delivery.png',
                height: bottomNavBarIconSize,
              ),
              title: Text('Delivery')),
          BottomNavigationBarItem(
              icon: Image.asset(
                'images/learn.png',
                height: bottomNavBarIconSize,
              ),
              title: Text('Learn')),
          BottomNavigationBarItem(
              icon: Image.asset(
                'images/service.png',
                height: bottomNavBarIconSize,
              ),
              title: Text('Service')),
          BottomNavigationBarItem(
              icon: Image.asset(
                'images/sell.png',
                height: bottomNavBarIconSize,
              ),
              title: Text('Sell')),
          BottomNavigationBarItem(
              icon: Image.asset(
                'images/rent.png',
                height: bottomNavBarIconSize,
              ),
              title: Text('Rent')),
          BottomNavigationBarItem(
              icon: Image.asset(
                'images/jobs.png',
                height: bottomNavBarIconSize,
              ),
              title: Text('Jobs')),
        ],
      ),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            var prediction = await PlacesAutocomplete.show(
                context: context,
                apiKey: kPlacesAPIKey,
                mode: Mode.overlay, // Mode.fullscreen
                language: "en",
                components: [Component(Component.country, 'my')]);

            if (prediction != null) {
              _locationSearchText.text = prediction.description;
              var mapsPlaces = GoogleMapsPlaces(apiKey: kPlacesAPIKey);
              var response =
                  await mapsPlaces.getDetailsByPlaceId(prediction.placeId);
              if (response != null) {
                var lat = response.result.geometry.location.lat;
                var long = response.result.geometry.location.lng;
                print('Lat Long = $lat:$long');

                _currentLocation['latitude'] = lat;
                _currentLocation['longitude'] = long;

                _refreshIndicatorKey.currentState.show();
              }
            }
          },
          child: AbsorbPointer(
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _locationSearchText,
              decoration: InputDecoration(
                  //contentPadding: EdgeInsets.only(top: 15.0),
                  border: InputBorder.none,
                  //suffixIcon: Icon(Icons.search),
                  hintText: 'Start typing a place',
                  hintStyle: TextStyle(fontStyle: FontStyle.italic)),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.pin_drop),
          tooltip: 'Get locations',
          onPressed: () async {
            //getting the location
            _currentLocation = await location.getLocation();
            print(
                'current loc | lat: ${_currentLocation['latitude']} long: ${_currentLocation['longitude']}');

            _locationSearchText.text = 'Your current location';

            //manipulateDataTable();
            _refreshIndicatorKey.currentState.show();
            Clipboard.setData(ClipboardData(
                text:
                    '${_currentLocation['latitude']},${_currentLocation['longitude']}'));
            await setLocation(
                _currentLocation['latitude'], _currentLocation['longitude']);
            print('location set in shared pref');
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('location obtained and copied'),
            ));
          },
        ),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Vendor Settings'),
                    value: 'vndr_sttngs',
                  ),
                  PopupMenuItem(
                    child: Text('TOS'),
                    value: 'tos',
                  ),
                  PopupMenuItem(
                    child: Text('Policy'),
                    value: 'policy',
                  ),
                  PopupMenuItem(
                    child: Text('Help'),
                    value: 'help',
                  ),
                ],
            onSelected: (selectedVal) {
              switch (selectedVal) {
                case 'vndr_sttngs':
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => VendorSettingsScreen(
                          _currentLocation["latitude"],
                          _currentLocation["longitude"],
                          widget._loggedInUser.uid)));
                  break;

                case 'tos':
                  launch('https://www.labuanservices.com/tos');
                  break;

                case 'policy':
                  launch('https://www.labuanservices.com/policy');
                  break;

                case 'help':
                  launch('https://www.labuanservices.com/help');
                  break;
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: manipulateDataTable,
        child: businessDetails.length > 0
            ? ListView(
                children: businessDetails
                    .map(
                      (business) => Card(
                            child: InkWell(
                              onTap: () {
                                var route = MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        VendorDetailsScreen(business.uid));
                                Navigator.of(context).push(route);
                              },
                              child: ListTile(
                                title: Text(
                                  business.businessName ?? 'Unspecified',
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                subtitle: Text(business.businessDesc ?? 'Unspecified'),
                                trailing: FittedBox(
                                  child: Column(
                                    children: <Widget>[
                                      Text(business.distance),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                      ),
                                      Image.asset('images/distance.png')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    )
                    .toList())
            : Center(
                child: FittedBox(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'images/notfound.png',
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      'No data to display.',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              )),
      ),
    );
  }
}
