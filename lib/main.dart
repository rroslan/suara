import 'package:flutter/material.dart';
import 'package:suara/models/anon_user.dart';
import 'package:suara/screens/phone_login.dart';
import 'package:suara/screens/vendor_details.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suara/screens/vendor_settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  var currentLocation = <String, double>{};
  var location = new Location();
  DatabaseReference _dbRef;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  @override
  void initState() {
      super.initState();
      _dbRef = FirebaseDatabase.instance.reference().child('AnonUsers');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: Icon(Icons.access_time), title: Text('Transport')),
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
            //log the user in anonymously
            FirebaseAuth.instance.signInAnonymously().then((FirebaseUser user){
              setState(() {
                              loggedInUser = user;
                            });

              //when login is success, we are getting the location details
              try{
                location.getLocation().then((val){
                  currentLocation = val;
                  var loggedInAnonUser = AnonymouseUser().toJson(user.uid, currentLocation["latitude"], currentLocation["longitude"]);

                  //finally, pushing the values to the cloud firestore
                  _dbRef.push().set(loggedInAnonUser);
                  /*Firestore.instance.collection('users').document().setData(loggedInAnonUser).then((e){
                    print('done');
                  }).catchError((e){print(e);});*/
                });
              }catch(e){
                print(e);
              }
            }).catchError((e){
              print(e);
            });
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Vendor Settings',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: loggedInUser != null ? () {
              var route = MaterialPageRoute(
                  builder: (BuildContext context) => loggedInUser.isAnonymous ? PhoneLoginScreen() : VendorSettingsScreen());

              Navigator.of(context).push(route);
            } : null,
          )
        ],
      ),
      body: DataTable(
        columns: [
          DataColumn(label: Text('Business Description')),
          DataColumn(label: Text('Distance'), numeric: true)
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('data'), onTap: () {
              var route = MaterialPageRoute(
                  builder: (BuildContext context) => VendorDetailsScreen());
              Navigator.of(context).push(route);
            }),
            DataCell(Text('1.0'))
          ]),
        ],
      ),
    );
  }
}
