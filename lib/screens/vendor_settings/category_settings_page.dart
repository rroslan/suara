import 'package:flutter/material.dart';

class CategoriesSettingsPage extends StatefulWidget {
  final String _initialValue;

  CategoriesSettingsPage(this._initialValue);

  @override
  State<StatefulWidget> createState() => CategoriesSettingsPageState();
}

class CategoriesSettingsPageState extends State<CategoriesSettingsPage> {
  final categoriesList = <String>[
    'Delivery',
    'Learn',
    'Service',
    'Sell',
    'Rent',
    'Jobs'
  ];

  String _selectedValue = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedValue = widget._initialValue == null
          ? categoriesList[0]
          : widget._initialValue.isEmpty
              ? categoriesList[0]
              : widget._initialValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a category'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'SAVE',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop(_selectedValue);
            },
          )
        ],
      ),
      body: ListView(
        children: categoriesList
            .map((cat) => RadioListTile(
                  groupValue: _selectedValue,
                  title: Text(cat),
                  value: cat,
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value;
                    });
                    print(value);
                  },
                ))
            .toList(),
      ),
    );
  }
}
