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

  String phoneNo = '+94766674770';
  String smsCode;
  String verificationId;

  Future<void> verifyPhone()async{
    final PhoneCodeSent smsCodeSent = (String veriId, [int forceCodeResend]){
      this.verificationId = veriId;
      smsCodeDialog(context).then((value){
        print('signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user){
      print('verified');
    };

    final PhoneVerificationFailed verificationFailed = (AuthException ex){
      print(ex.message);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: this.phoneNo,
      codeAutoRetrievalTimeout: (veriId){
        verificationId = veriId;
      },
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verificationFailed
    );
  }

  Future<bool> smsCodeDialog(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return new AlertDialog(
          title: Text('Enter SMS code'),
          content: TextField(
            onChanged: (value){
              this.smsCode = value;
            },
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                FirebaseAuth.instance.currentUser().then((user){
                  if(user!=null){
                    Navigator.of(context).pop();
                  }else{
                    Navigator.of(context).pop();
                    signIn();
                  }
                });
              },
            )
          ],
        );
      }
    );
  }

  signIn(){
    FirebaseAuth.instance.signInWithPhoneNumber(
      verificationId: this.verificationId,
      smsCode: this.smsCode
    ).then((user){

    }).catchError((error){
      print(error);
    });
  }

  @override
  void initState() {
      super.initState();
      _dbRef = FirebaseDatabase.instance.reference().child('AnonUsers');
      verifyPhone();
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
                  builder: (BuildContext context) => loggedInUser.isAnonymous ? PhoneLoginScreen(currentLocation["latitude"], currentLocation["longitude"]) : VendorSettingsScreen(currentLocation["latitude"], currentLocation["longitude"]));

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
