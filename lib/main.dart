import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suara/common/common.dart';
import 'package:suara/models/anon_user.dart';
import 'package:suara/models/vendor_settings.dart';
import 'package:suara/models/vendors.dart';
import 'package:suara/screens/phone_login.dart';
import 'package:suara/screens/vendor_details.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suara/screens/vendor_settings.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: /*MyHomePage(title: 'Flutter Demo Home Page')*/ FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(
              snapshot.data,
              title: 'Flutter Demo Home Page',
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
      body: Center(
        child: RaisedButton(
          color: Colors.red.shade700,
          child: Text(
            'Login with Google',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            initiateGoogleLogin(context);
          },
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  var currentLocation = <String, double>{};
  var location = new Location();
  DatabaseReference _dbRef;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirebaseUser _loggedInUser;
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
    if (currentLocation.values.length == 0) {
      var result = await showLocationNullValidationDialog();
      if (result) {
        currentLocation = await location.getLocation();
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
                : _currentIndex == 3 ? 'Sell' : 'Rent';
    var latitude = currentLocation['latitude'];
    var longitude = currentLocation['longitude'];
    var radiusInKm = _currentIndex == 0
        ? 20.0
        : _currentIndex == 1.0
            ? 700.0
            : _currentIndex == 2 ? 30.0 : _currentIndex == 3 ? 10.0 : 10.0;

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
        var vendor = VendorSettings.fromJson(data.data);
        final distance = new Distance();
        final km = distance.as(
            LengthUnit.Kilometer,
            LatLng(vendor.location['latitude'], vendor.location['longitude']),
            LatLng(currentLocation['latitude'], currentLocation['longitude']));
        setState(() {
          businessDetails.add(Vendors(
              vendor.uid, vendor.businessName, vendor.businessDesc, '$km km'));
        });
        subscription.cancel();
      });
    }

    print(listOfKeys.length);
  }

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.reference().child('AnonUsers');
    /*FirebaseAuth.instance.currentUser().then((user) {
      if (user == null) {
      } else {
        setState(() {
          loggedInUser = user;
        });
      }
    });*/
    //when the widget is build, then runs this callback
    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
          currentLocation = await location.getLocation();
          Clipboard.setData(ClipboardData(
                text:
                    '${currentLocation['latitude']},${currentLocation['longitude']}'));
          _refreshIndicatorKey.currentState.show();
        });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
              icon: Image.asset('images/delivery.png'), title: Text('Delivery')),
          BottomNavigationBarItem(
              icon: Image.asset('images/learn.png'), title: Text('Learn')),
          BottomNavigationBarItem(
              icon: Image.asset('images/service.png'), title: Text('Service')),
          BottomNavigationBarItem(
              icon: Image.asset('images/sell.png'), title: Text('Sell')),
          BottomNavigationBarItem(
              icon: Image.asset('images/rent.png'), title: Text('Rent')),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.pin_drop),
          tooltip: 'Get locations',
          onPressed: () async {
            //getting the location
            currentLocation = await location.getLocation();
            manipulateDataTable();
            Clipboard.setData(ClipboardData(
                text:
                    '${currentLocation['latitude']},${currentLocation['longitude']}'));
            await setLocation(
                currentLocation['latitude'], currentLocation['longitude']);
            print('location set in shared pref');
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('location obtained and copied'),
            ));
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Vendor Settings',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              print('${widget._loggedInUser.uid}');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => VendorSettingsScreen(
                      currentLocation["latitude"],
                      currentLocation["longitude"],
                      widget._loggedInUser.uid)));
            },
          )
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
                                  business.businessName,
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                subtitle: Text(business.businessDesc),
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
