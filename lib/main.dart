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

  BluetoothManagerStateless bluetoothManager;

  ContactManager contactManager;

  int homeDisplayNum = 0; // 0 : contacts, 1 : bluetooth

  @override
  void initState() {
    super.initState();

    this.bluetoothManager = BluetoothManagerStateless();
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
          addNearbyDevicesToContacts();
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
    }
    print('this statement should be unreachable');
  }

  void addNearbyDevicesToContacts() async {
    List<BluetoothDevice> nearbyDevices = await this.bluetoothManager.updateNearbyDevices();

    print('nearby devices are:');
    for (BluetoothDevice d in nearbyDevices) {
      print(d.name);
    }
    

//    this.bluetoothManager.updateNearbyDevices().then((value) {
//      print('nearby devices are $value');
//    });
  }

}
