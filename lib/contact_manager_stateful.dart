import 'contact.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class ContactManagerStateful extends StatefulWidget {
  @override
  _ContactManagerStatefulState createState() => _ContactManagerStatefulState();
}

class _ContactManagerStatefulState extends State<ContactManagerStateful> {
  Map<String, Contact> contactMap;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    this.databaseHelper = DatabaseHelper();
    this.contactMap = new HashMap<String, Contact>();
    this.refreshContactMap();
  }

  void refreshContactMap() async {
    List<Contact> tempList = await databaseHelper.getContactList();
    for (int i = 0; i < tempList.length; i++) {
      Contact tempContact = tempList[i];
      this.contactMap[tempContact.theirID] = tempContact;
    }
  }

  Future<int> saveContact(theirID, int count24, theirName) async {
    int result;
    if (this.contactMap.containsKey(theirID)) {
      Contact tempContact = this.contactMap[theirID];
      tempContact.their24HourContactCount = count24;
      result = await databaseHelper.updateContact(tempContact);
    } else {
      Contact tempContact = Contact.withoutTime(count24, theirID, theirName);
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
          String key = this.contactMap.keys.elementAt(index);
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
