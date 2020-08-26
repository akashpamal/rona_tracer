import 'package:flutter/material.dart';

class ListTest extends StatefulWidget {
  @override
  _ListTestState createState() => _ListTestState();
}

class _ListTestState extends State<ListTest> {
  List<int> nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('List Test'),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: nums.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(
                  nums[index].toString(),
                ),
              ),
            );
          }),
    );
  }
}
