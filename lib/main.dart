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

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map<int, Contact> contactMap;

  DatabaseHelper databaseHelper;

  BluetoothManager bluetoothManager;

  int homeDisplayNum = 0; // 0 : contacts, 1 : bluetooth

  @override
  void initState() {
    super.initState();
    this.refreshContactMap();

    this.databaseHelper = DatabaseHelper();
    this.bluetoothManager = BluetoothManager();
    this.contactMap = new HashMap<int, Contact>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refreshContactMap() async {
    List<Contact> tempList = await databaseHelper.getContactList();
    for (int i = 0; i < tempList.length; i++) {
      Contact tempContact = tempList[i];
      this.contactMap[tempContact.theirID] = tempContact;
    }
  }

  Future<int> saveContact(theirID, int count24) async {
    int result;
    if (this.contactMap.containsKey(theirID)) {
      Contact tempContact = this.contactMap[theirID];
      tempContact.their24HourContactCount = count24;
      result = await databaseHelper.updateContact(tempContact);
    } else {
      Contact tempContact = Contact.withoutTime(count24, theirID);
      result = await databaseHelper.insertContact(tempContact);
      this.contactMap[theirID] = tempContact;
    }
    print('finished saving contact');
    return result;
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
    );
  }

  Widget appropriateHomeList() {
    switch (this.homeDisplayNum) {
      case 0:
        return this.contactsListWidget();
        break;
      case 1:
        return this.bluetoothManager;
        break;
    }
    print('this statement should be unreachable');
  }

  Widget contactsListWidget() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: this.contactMap.length,
        itemBuilder: (context, index) {
          int key = this.contactMap.keys.elementAt(index);
          return Card(
            child: ListTile(
              title: Text(
                this.contactMap[key].toString(),
              ),
            ),
          );
        });
  }
}
