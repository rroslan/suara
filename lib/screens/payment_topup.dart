import 'package:flutter/material.dart';

class PaymentTopUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment TopUp'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('10 credits'),
            trailing: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.all(5.0),
                child: Text('RM 15'),
              ),
            ),
          ),
          ListTile(
            title: Text('20 credits'),
            trailing: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5.0)
                ),
                padding: EdgeInsets.all(5.0),
                child: Text('RM 22'),
              ),
            ),
          ),
          ListTile(
            title: Text('30 credits'),
            trailing: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5.0)
                ),
                padding: EdgeInsets.all(5.0),
                child: Text('RM 30'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
