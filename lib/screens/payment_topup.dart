import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentTopUpScreen extends StatelessWidget {
  final _phoneNo;

  PaymentTopUpScreen(this._phoneNo);

  void makePhoneCall() async {
    var url = 'tel:$_phoneNo';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  void sendSMS() async {
    var url = 'sms:$_phoneNo';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  void openWhatsapp() async {
    var url = 'https://api.whatsapp.com/send?phone=$_phoneNo';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment TopUp'),
      ),
      body: ListView(
        children: <Widget>[       
          ListTile(
            title: Text('Contact your sales agent to top up credits and increase the lifetime of your usage',style: TextStyle(color: Colors.grey),),
          ),
          ListTile(
            title: Text('Call'),
            subtitle: Text('Make a phone call'),
            trailing: Icon(
              Icons.phone,
              color: Colors.black,
            ),
            onTap: () {
              if (_phoneNo != null) {
                makePhoneCall();
              }
            },
          ),
          ListTile(
            title: Text('SMS'),
            subtitle: Text('Send a message'),
            trailing: Icon(
              Icons.sms,
              color: Colors.black,
            ),
            onTap: () {
              if (_phoneNo != null) {
                sendSMS();
              }
            },
          ),
          ListTile(
            title: Text('Whatsapp'),
            subtitle: Text('Open up'),
            trailing: Image.asset(
              'images/whatsapp.png',
              scale: 1.2,
            ),
            onTap: () {
              if (_phoneNo != null) {
                openWhatsapp();
              }
            },
          ),
        ],
      ),
    );
  }
}
