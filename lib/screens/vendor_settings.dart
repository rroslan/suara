import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:suara/screens/payment_topup.dart';



class VendorSettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VendorSettingsScreenState();
}

class VendorSettingsScreenState extends State<VendorSettingsScreen>{
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  var _ratingVal = 0.0;

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
                content: Text(val?'Online' : 'Offline'),
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
                    builder: (BuildContext context)=>PaymentTopUpScreen()
                  );

                  Navigator.of(context).push(route);
                },
              )
            ],
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 50.0,
          ),
          Text('Upload Picture'),
          Text('Business Name'),
          Text('Business Description'),
          Text('Facebook Page URL'),
          Text('Location 1'),
          TextField(),
          Text('Location 2'),
          TextField(),
          Text('Ratings'),
          StarRating(
            rating: _ratingVal,
            size: 50.0,
            onRatingChanged: (val){
              setState(() {
                              _ratingVal = val;
                            });
            },
          ),
          RaisedButton(
            onPressed: (){},
            child: Text('Save'),
          )
        ],
      ),
    );
  }
}
