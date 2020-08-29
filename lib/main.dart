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

  int homeDisplayNum = 0; // 0 : contacts, 1 : bluetooth, 2 : loading

  String loadingText = 'loading...';

  @override
  void initState() {
    super.initState();

    this.bluetoothManager = BluetoothManager();
    this.contactManager = ContactManager();
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

              });
            },
            child: Text('delete all contacts'),
          ),
          SizedBox(height: 8.0),
//          Container(
//            height: 500.0,
//              child: ListView.builder(
//                shrinkWrap: true,
//                itemCount: 10,
//                itemBuilder: (context, index) {
//                  return Card(
//                    child: ListTile(
//                      onTap: () {
//                        print('$index was clicked');
//                      },
//                      title: Text(
//                        index.toString(),
//                      ),
//                    ),
//                  );
//                },
//              ),
//          ),
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
    });

    List<BluetoothDevice> nearbyDevices =
        await this.bluetoothManager.getNearbyDevices();

    nearbyDevices.forEach((element) {
      print(element.name);
    });
    print('${nearbyDevices.length} devices found');

    List<Future<bool>> futureBools = [];
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
        await this.contactManager.addContact(theirID, 1, d.name);
        this.setState(() {
          this.homeDisplayNum = 0;
        });
      }
    }

    print('done checking nearby devices');
    setState(() {
      this.homeDisplayNum = 0;
      print('rebuilding home widget');
    });
  }
}
