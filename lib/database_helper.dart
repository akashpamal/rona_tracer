import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'contact.dart';
import 'package:path_provider_macos/path_provider_macos.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String contactsTable = 'contacts_table';
  String colId = 'id';
  String colTheir24HourContactCount = 'their_24_hour_contact_count';
  String colTheirID = 'their_id';
  String theirName = 'their_name';
  String colDateTime = 'date_time';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path to store the database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/contacts.db';

    var contactsDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb);
    return contactsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $contactsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTheir24HourContactCount INTEGER, '
            '$colTheirID STRING, $theirName STRING, $colDateTime TEXT)');
  }

  Future<List<Map<String, dynamic>>> getContactMapList() async {
    Database db = await this.database;

//    var result = await db.query(contactsTable, orderBy: '$colTheir24HourContactCount ASC');
    var result = await db.query(contactsTable);
    return result;
  }

  Future<int> insertContact(Contact contact) async {
    Database db = await this.database;
    var result = await db.insert(contactsTable, contact.toMap());
    return result;
  }

  Future<int> updateContact(Contact contact) async {
    Database db = await this.database;
    var result = await db.update(contactsTable, contact.toMap(),
        where: '$colId = ?', whereArgs: [contact.id]);
    return result;
  }

  Future<int> deleteContact(int id) async {
    Database db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $contactsTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $contactsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Contact>> getContactList() async {
    var contactMapList = await getContactMapList();
    int count = contactMapList.length;

    List<Contact> contactList = List<Contact>();

    for (int i = 0; i < count; i++) {
      contactList.add(Contact.fromMapObject(contactMapList[i]));
    }
    return contactList;
  }
}
