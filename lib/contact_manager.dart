import 'contact.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class ContactManager extends StatelessWidget {
  Map<int, Contact> contactMap;
  DatabaseHelper databaseHelper;

  ContactManager() {
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
    print('refreshing contact map');
  }

  Future<int> addContact(theirID, int count24, String theirName) async {
    int result;
    print('start saving contact');
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

  Future<int> deleteAll() async {
    List<Contact> contactList = await this.databaseHelper.getContactList();
    contactList.forEach((element) {
      this.databaseHelper.deleteContact(element.id);
    });
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
