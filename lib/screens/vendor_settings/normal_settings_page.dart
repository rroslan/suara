import 'package:flutter/material.dart';

class NormalSettingsPage extends StatelessWidget {
  final String _appBarTitle;
  final String _initialValue;
  final TextEditingController _txt1 = TextEditingController(text: '');

  NormalSettingsPage(this._appBarTitle, this._initialValue);

  @override
  Widget build(BuildContext context) {
    _txt1.text = _initialValue;

    return Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(_txt1.text);
              },
            )
          ],
        ),
        body: ListView(children: <Widget>[
          ListTile(
            title: _appBarTitle.toLowerCase() == 'business description'
                ? TextField(
                    controller: _txt1,
                    autofocus: true,
                    maxLines: 10,
                    decoration: InputDecoration(
                        labelText: 'Enter a business description'),
                  )
                : TextField(
                    controller: _txt1,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: _appBarTitle.toLowerCase() == 'business name' ? 'Enter a business name' : _appBarTitle.toLowerCase() == 'fb page url' ? 'Enter an FB page URL' : _appBarTitle.toLowerCase() == 'whatsapp no' ? 'Enter a Whatsapp No' : _appBarTitle.toLowerCase() == 'sales contact' ? 'Enter a Sales Contact Number' : 'Enter a phone number',
                        prefix: _appBarTitle.toLowerCase() == 'fb page url'
                            ? Container(child: Text('http://m.facebook.com/'))
                            : null),
                  ),
          )
        ]));
  }
}
