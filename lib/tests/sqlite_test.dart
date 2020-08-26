import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rona_tracer_v2/contact.dart';
import 'package:rona_tracer_v2/database_helper.dart';
import 'dart:collection';

class SQLTest extends StatefulWidget {
  @override
  _SQLTestState createState() => _SQLTestState();
}

class _SQLTestState extends State<SQLTest> {
  final textField24HourCount = TextEditingController();
  final textFieldTheirID = TextEditingController();

  int result;
  Map<int, Contact> contactList = new HashMap<int, Contact>();

  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void dispose() {
    textField24HourCount.dispose();
    textFieldTheirID.dispose();
    super.dispose();
  }

  @override
  void initState() {
    this.refreshContactList();
    super.initState();
  }

  void refreshContactList() async {
    List<Contact> tempList = await databaseHelper.getContactList();
    for (int i = 0; i < tempList.length; i++) {
      Contact tempContact = tempList[i];
      this.contactList[tempContact.theirID] = tempContact;
    }
  }

  Future<int> saveContact(int count24, int theirID) async {
    if (this.contactList.containsKey(theirID)) {
      Contact tempContact = this.contactList[theirID];
      tempContact.their24HourContactCount = count24;
      this.result = await databaseHelper.updateContact(tempContact);
    } else {
      Contact tempContact = Contact.withoutTime(count24, theirID);
      this.result = await databaseHelper.insertContact(tempContact);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQL Test'),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () async {
            List<Contact> temp = await databaseHelper.getContactList();
            for (int i = 0; i < temp.length; i++) {
              print(temp[i]);
            }
          },
          color: Colors.red,
          child: Text('print contacts database to screen'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.9)),
                  child: Container(
                    height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: this.textField24HourCount,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Their 24 hour contact count'),
                            ),
                            TextField(
                              controller: this.textFieldTheirID,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Their ID'),
                            ),
                            SizedBox(
                              width: 320.0,
                              child: RaisedButton(
                                onPressed: () {
                                  int count24 =
                                  int.parse(textField24HourCount.text);
                                  int theirID =
                                  int.parse(textFieldTheirID.text);
                                  this.saveContact(count24, theirID);
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: const Color(0xFF1BC0C5),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
