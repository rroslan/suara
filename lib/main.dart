import 'package:flutter/material.dart';
import 'package:suara/common/common.dart';
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
          //navigateToWelcomePage(context, WelcomeScreen());
          print('signed in');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MyHomePage()));
        });
      }).catchError((error) {
        /*scaffoldKey.currentState
          .showSnackBar(errorSnackBar(scaffoldKey, error.message));*/
        print(error.message);
      });
    }).catchError((error) {
      /*scaffoldKey.currentState
        .showSnackBar(errorSnackBar(scaffoldKey, error.message));*/
      print(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          color: Colors.red.shade700,
          child: Text('Login with Google',style: TextStyle(color: Colors.white),),
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

  /*String phoneNo = '+94766674770';
  String smsCode;
  String verificationId;*/

  /*Future<void> verifyPhone() async {
    final PhoneCodeSent smsCodeSent = (String veriId, [int forceCodeResend]) {
      this.verificationId = veriId;
      smsCodeDialog(context).then((value) {
        print('signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('verified');
    };

    final PhoneVerificationFailed verificationFailed = (AuthException ex) {
      print(ex.message);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: (veriId) {
          verificationId = veriId;
        },
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: verificationFailed);
  }*/

  /*Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS code'),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }*/

  /*Future<void> phoneNumberRequestDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter phone number'),
            content: TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                this.phoneNo = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }*/

  /*signIn() {
    FirebaseAuth.instance
        .signInWithPhoneNumber(
            verificationId: this.verificationId, smsCode: this.smsCode)
        .then((user) {})
        .catchError((error) {
      print(error);
    });
  }*/

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

            await setLocation(
                currentLocation['latitude'], currentLocation['longitude']);
            print('location set in shared pref');
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('location obtained and copied'),
            ));

            //when login is success, we are getting the location details
            /*try{
                location.getLocation().then((val){
                  currentLocation = val;
                  var loggedInAnonUser = AnonymouseUser().toJson(user.uid, currentLocation["latitude"], currentLocation["longitude"]);

                  //finally, pushing the values to the cloud firestore
                  _dbRef.push().set(loggedInAnonUser);*/
            /*Firestore.instance.collection('users').document().setData(loggedInAnonUser).then((e){
                    print('done');
                  }).catchError((e){print(e);});*/
            /*});
              }catch(e){
                print(e);
              }*/

            /*}).catchError((e) {
              print(e);
            });*/
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Vendor Settings',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              /*var route = MaterialPageRoute(
                  builder: (BuildContext context) => loggedInUser.isAnonymous ? PhoneLoginScreen(currentLocation["latitude"], currentLocation["longitude"]) : VendorSettingsScreen(currentLocation["latitude"], currentLocation["longitude"]));

              Navigator.of(context).push(route);*/
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
