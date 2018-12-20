import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';



class VendorDetailsScreen extends StatelessWidget {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Vendor Details'),
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
          Text('Ratings'),
          StarRating(
            rating: 1.0,
            size: 50.0,
          )
        ],
      ),
    );
  }
}
