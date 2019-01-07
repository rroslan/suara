import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suara/common/common.dart';
import 'package:suara/models/anon_user.dart';
import 'package:suara/models/vendors.dart';
import 'package:suara/screens/phone_login.dart';
import 'package:suara/screens/vendor_details.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suara/screens/vendor_settings.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

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
            return MyHomePage(title: 'Flutter Demo Home Page');
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MyHomePage()));
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
  FirebaseUser loggedInUser;
  var businessDetails = <Vendors>[
  
  ];

  void manipulateDataTable() async {
    var latitude = currentLocation['latitude'];
    var longitude = currentLocation['longitude'];
    var radiusInKm = _currentIndex == 0
        ? 20.0
        : _currentIndex == 1
            ? 700.0
            : _currentIndex == 2 ? 30.0 : _currentIndex == 3 ? 10.0 : 10.0;

    var listOfKeys =
        await Geofire.queryAtLocation(latitude, longitude, radiusInKm);
    print(listOfKeys.length);
  }

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.reference().child('AnonUsers');
    FirebaseAuth.instance.currentUser().then((user) {
      if (user == null) {
        /*phoneNumberRequestDialog(context).then((value){
          verifyPhone();
        });*/
      } else {
        setState(() {
          loggedInUser = user;
        });
      }
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
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), title: Text('Delivery')),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), title: Text('Learn')),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), title: Text('Service')),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), title: Text('Sell')),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), title: Text('Rent')),
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
                    'Lat: ${currentLocation['latitude']} | Long: ${currentLocation['longitude']}'));
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
              print('${loggedInUser.uid}');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => VendorSettingsScreen(
                      currentLocation["latitude"],
                      currentLocation["longitude"],
                      loggedInUser.uid)));
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          SingleChildScrollView(
            child: DataTable(
        columns: [
          DataColumn(label: Text('Business Description')),
          DataColumn(label: Text('Distance'), numeric: true)
        ],
        rows: businessDetails
            .map((business) => DataRow(cells: [
                  DataCell(Text(business.businessDesc), onTap: () {
                    var route = MaterialPageRoute(
                        builder: (BuildContext context) =>
                            VendorDetailsScreen());
                    Navigator.of(context).push(route);
                  }),
                  DataCell(Text(business.distance))
                ]))
            .toList(),
      ),
          )
        ],
      ),
    );
  }
}
