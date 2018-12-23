import 'package:flutter/material.dart';
import './services.dart' as services;
import './delivery.dart' as delivery;
import './rent.dart' as rent;
import './sell.dart' as sell;
import './learn.dart' as learn;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 5);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Suara Biz'),
          backgroundColor: Colors.teal,

        ),
        bottomNavigationBar: new Material(
            color: Colors.teal,
            child: new TabBar(
              controller: controller,
              tabs: <Widget>[
                new Tab(icon: new Icon(Icons.developer_mode)),
                new Tab(icon: new Icon(Icons.airport_shuttle)),
                new Tab(icon: new Icon(Icons.autorenew)),
                new Tab(icon: new Icon(Icons.add_shopping_cart)),
                new Tab(icon: new Icon(Icons.book)),
              ],
            )
        ),
        body: new TabBarView(
          controller: controller,
          children: <Widget>[
            new services.Services(),
            new delivery.Delivery(),
            new rent.Rent(),
            new sell.Sell(),
            new learn.Learn(),
          ],
        )
    );
  }
}