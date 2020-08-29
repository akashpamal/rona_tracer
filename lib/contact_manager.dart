import 'contact.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class ContactManager extends StatelessWidget {
  Map<String, Contact> contactMap;
  DatabaseHelper databaseHelper;

  ContactManager() {
    this.databaseHelper = DatabaseHelper();
    this.contactMap = new HashMap<String, Contact>();
    this.refreshContactMap();
  }

  void refreshContactMap() async {
    print('refreshing contact map');
    List<Contact> tempList = await databaseHelper.getContactList();
    for (int i = 0; i < tempList.length; i++) {
      Contact tempContact = tempList[i];
      this.contactMap[tempContact.theirID] = tempContact;
    }
    print('contact map: ${this.contactMap}');
  }

  Future<bool> addContact(theirID, int count24, String theirName) async {
//    int result;
    bool alreadyIn;
    print('start saving contact named $theirName');
    if (this.contactMap.containsKey(theirID)) {
      print('already in database, over-writing');
      Contact tempContact = this.contactMap[theirID];
      print('tempContact: $tempContact');
      tempContact.their24HourContactCount = count24;
      tempContact.dateTime = DateTime.now().toString();
      print('tempContact: $tempContact');
//      result = await databaseHelper.updateContact(tempContact);
      alreadyIn = true;
    } else {
      print('not in database, adding now');
      Contact tempContact = Contact.withoutTime(count24, theirID, theirName);
//      result = await databaseHelper.insertContact(tempContact);
      alreadyIn = false;
      this.contactMap[theirID] = tempContact;
    }
    print('finished saving contact');
    return alreadyIn;
  }

  Future<int> deleteAll() async {
    List<Contact> contactList = await this.databaseHelper.getContactList();
    contactList.forEach((element) async {
      this.contactMap.remove(element.theirID);
      await this.databaseHelper.deleteContact(element.id);
      print('deleted device with id ${element.id}');
    });
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
