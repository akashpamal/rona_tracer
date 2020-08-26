import 'contact.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class ContactManager extends StatefulWidget {
  @override
  _ContactManagerState createState() => _ContactManagerState();
}

class _ContactManagerState extends State<ContactManager> {
  Map<int, Contact> contactMap;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    this.databaseHelper = DatabaseHelper();
    this.contactMap = new HashMap<int, Contact>();
    this.refreshContactMap();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      child: this.contactsListWidget(),
    );
  }
}
