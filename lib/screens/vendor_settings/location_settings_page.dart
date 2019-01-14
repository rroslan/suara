import 'package:flutter/material.dart';

class LocationSettingsPage extends StatefulWidget {
  final String _appBarTitle;
  final String _initialValue;

  final bool isChecked;

  LocationSettingsPage(this._appBarTitle, this._initialValue, this.isChecked);

  @override
  State<StatefulWidget> createState() => LocationSettingsPageState();
}

class LocationSettingsPageState extends State<LocationSettingsPage> {
  bool _isChecked;
  final TextEditingController _txt1 = TextEditingController(text: '');
  final TextEditingController _txt2 = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _txt1.text =
        widget._initialValue != null ? widget._initialValue.split('|')[0] : '';
    _txt2.text =
        widget._initialValue != null ? widget._initialValue.split('|')[1] : '';
    _isChecked = widget._initialValue != null
        ? widget._appBarTitle.toLowerCase() == 'location'
            ? widget._initialValue.split('|')[2].toLowerCase() == 'true'
            : widget._appBarTitle.toLowerCase() == 'location 2'
                ? widget._initialValue.split('|')[2].toLowerCase() != 'true'
                : false
        : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget._appBarTitle),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                dynamic returnVal = {
                  'latitude': _txt1.text,
                  'longitude': _txt2.text,
                  'isChecked': _isChecked
                };
                Navigator.of(context).pop(returnVal);
              },
            )
          ],
        ),
        body: ListView(children: <Widget>[
          ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _txt1,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Enter latitude'),
                ),
                TextField(
                  controller: _txt2,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Enter longitude'),
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Checkbox(
                      value: _isChecked,
                      onChanged: (val) {
                        setState(() {
                          _isChecked = val;
                        });
                      },
                    ),
                    Text('Default location')
                  ],
                )
              ],
            ),
          )
        ]));
  }
}
