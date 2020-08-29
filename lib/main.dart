import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rona_tracer_v2/database_helper.dart';
import 'tests/sqlite_test.dart';
import 'tests/uuid_test.dart';
import 'tests/bluetooth_test.dart';
import 'contact.dart';
import 'dart:collection';
import 'package:flutter_blue/flutter_blue.dart';
import 'bluetooth_manager.dart';
import 'contact_manager.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothManager bluetoothManager;

  ContactManager contactManager;

  int homeDisplayNum = 2; // 0 : contacts, 1 : bluetooth, 2 : loading

  String loadingText = 'loading...';

  int numNewDevices = 0;
  int numOldDevices = 0;

  @override
  void initState() {
    super.initState();
    this.initManagers();
  }

  void initManagers() async {
    this.bluetoothManager = BluetoothManager();
    this.contactManager = await ContactManager();
    this.setState(() {
      this.homeDisplayNum = 0;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Rona Tracer'),
      ),
      backgroundColor: Colors.amber,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: Colors.green,
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                'Your contacts at a glance:',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          RaisedButton(
            onPressed: () async {
              await this.contactManager.deleteAll();
              this.setState(() {
                print('rebuilding home widget');
              });
            },
            child: Text('delete all contacts'),
          ),
          SizedBox(height: 8.0),
          Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.blue,
            child: Text(
              '${this.numNewDevices} new devices discovered',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Container(
            color: Colors.blue,
            child: Text(
              '${this.numNewDevices + this.numOldDevices} total devices discovered',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          this.appropriateHomeList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('floating action button presed');
          addNearbyDevicesToContacts();
          print('contacts: ${this.contactManager.contactMap}');
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget appropriateHomeList() {
    switch (this.homeDisplayNum) {
      case 0:
        return this.contactManager;
        break;
      case 1:
        return this.bluetoothManager;
        break;
      case 2:
        return Text(this.loadingText);
        break;
    }
    print('this statement should be unreachable');
  }

  void addNearbyDevicesToContacts() async {
    this.setState(() {
      this.homeDisplayNum = 2;
      this.numOldDevices = 0;
      this.numNewDevices = 0;
    });

    List<BluetoothDevice> nearbyDevices =
        await this.bluetoothManager.getNearbyDevices();

    nearbyDevices.forEach((element) {
      print(element.name);
    });
    print('${nearbyDevices.length} devices found');

    int numNew = 0;
    int numOld = 0;
    //todo scan multiple devices at the same time
    for (BluetoothDevice d in nearbyDevices) {
      print('device named: ${d.name}');
      this.setState(() {
        this.homeDisplayNum = 2;
        this.loadingText = 'processing device named ${d.name}';
        // todo add info to the ui about whether the device was a phone
      });
      bool isPhoneBool = await this
          .bluetoothManager
          .deviceIsPhone(d)
          .timeout(Duration(seconds: 10), onTimeout: () {
        //todo fix the timeout i think there's still smth wrong with it
        print('connecting to device ${d.name} timed out');
        return false;
      });

      String isPhoneString = isPhoneBool ? 'is a phone.' : 'is not a phone.';
      print('${d.name} $isPhoneString');

      if (isPhoneBool) {
//        int theirID = d.name.toString().hashCode;
        String theirID = d.id.toString();
        print('their id is $theirID');
        print('going to invoke addContact method on ${d.name}');
        bool alreadyIn =
            await this.contactManager.addContact(theirID, 1, d.name);
        if (alreadyIn) {
          numOld++;
        } else {
          numOld++;
        }
        this.setState(() {
          this.homeDisplayNum = 0;
          this.numOldDevices = numOld;
          this.numNewDevices = numNew;
        });
      }
    }

    print('done checking nearby devices');
    setState(() {
      this.homeDisplayNum = 0;
      this.numOldDevices = numOld;
      this.numNewDevices = numNew;
      print('rebuilding home widget');
    });
  }
}
