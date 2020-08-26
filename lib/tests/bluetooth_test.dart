import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rona_tracer_v2/contact.dart';
import 'package:rona_tracer_v2/database_helper.dart';
import 'dart:collection';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothTest extends StatefulWidget {
  @override
  _BluetoothTestState createState() => _BluetoothTestState();
}

class _BluetoothTestState extends State<BluetoothTest> {
  void updateAvailableDevices() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    Future.delayed(const Duration(seconds: 4), () {
      var subscription = flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
      });
      print('subscription: $subscription');
      // Stop scanning
      flutterBlue.stopScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Test'),
        backgroundColor: Colors.purple,
      ),
      body: RaisedButton(
        onPressed: () {
          print('middle button');
//          getResults();
        },
        child: Text('useless button'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('floating action button pressed');
          updateAvailableDevices();
        },
        child: Icon(Icons.bluetooth),
      ),
    );
  }
}
