import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UUIDTest extends StatefulWidget {
  @override
  _UUIDTestState createState() => _UUIDTestState();
}

class _UUIDTestState extends State<UUIDTest> {

  void getId() async {
    print('getting instance of shared preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('got instance of shared preferences');
    var uuid = Uuid();

    String my_id = (prefs.getString('my_id') ?? uuid.v4());
    await prefs.setString('my_id', my_id);
    print('my id is $my_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('UUID Test'),
        centerTitle: true,
      ),
      body: Text('i am a scaffold'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('uuid floaing action has been pressed');
          this.getId();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
