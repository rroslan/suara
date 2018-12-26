import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
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
  //var c= widget._latitude;
  //var _latTxtController = TextEditingController(text: widget._latitude.toString());
  //var _longTxtController = TextEditingController(text: widget._longitude.toString());

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
          ),
          ListTile(
            title: Text('Business Description'),
            subtitle: Text('Untitled'),
          ),
          ListTile(
            title: Text('FB Page URL'),
            subtitle: Text('Untitled'),
          ),
          ListTile(
            title: Text('Locations'),
            subtitle: Text('asd'),
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
          /*ListTile(
            title: Flex(
              direction: Axis.vertical,
              children: <Widget>[Container()],
            ),
          ),*/
          ListTile(
            title: RaisedButton(
              color: Colors.blue,
              onPressed: () {},
              child: Text('Save'),
            ),
          )
        ],
      ),
    );
  }
}
