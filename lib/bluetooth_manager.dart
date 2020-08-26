import 'dart:collection';
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

class BluetoothManager extends StatefulWidget {
  BluetoothManager();

  @override
  _BluetoothManagerState createState() => _BluetoothManagerState();
}

class _BluetoothManagerState extends State<BluetoothManager> {
  Set<BluetoothDevice> nearbyDevices = HashSet();
  List<BluetoothService> availableServices = [];
  List<BluetoothCharacteristic> serviceCharacteristics = [];

  BluetoothDevice connectedDevice;

  int btDisplayNum = 1; // 0 : loading, 1 : nearbyDevices, 2 : availableServices

  Future<int> updateNearbyDevices() async {
    print('updating nearby devices...');
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    this.nearbyDevices.clear();
    int count = 0;
    flutterBlue.scanResults.listen((results) {
      count++;
      print('count is $count');
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name != '' || r.rssi >= -80) {
          this.nearbyDevices.add(r.device);
        }
      }
      // Stop scanning
    }, onDone: () {
      print('done scanning');
    });
//    Future.delayed(const Duration(milliseconds: 4500), () {
//      print('about to rebuild bluetooth widget');
//      this.setState(() {});
//    });
//    print('about to rebuild home widget from updateAvailableDevices()');
//    print('stopping the scan');
    flutterBlue.stopScan();
  }

  void updateAvailableServices() async {
    print('available services from connected device:');
    this.availableServices.clear();
    List<BluetoothService> services =
        await this.connectedDevice.discoverServices();
    services.forEach((service) {
      print(service);
      this.availableServices.add(service);
    });
    this.setState(() {
      this.btDisplayNum = 2;
    });
  }

  void printAvailableCharacteristics() async {
    print('available characteristics from connected device:');
//    this.serviceCharacteristics.clear();
//    List<BluetoothService> characteristics =
//    await this.connectedDevice.discoverServices();

    this.availableServices.forEach((service) {
      print(service);
      this.availableServices.add(service);
    });
    this.setState(() {
      this.btDisplayNum = 2;
    });
  }

  Widget nearbyDevicesListWidget() {
    print('displaying nearby devices');
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: this.nearbyDevices.length,
        itemBuilder: (context, index) {
          List<BluetoothDevice> nearbyDevicesList = this.nearbyDevices.toList();
          return Card(
            child: ListTile(
              onTap: () {
                this.connectToDevice(nearbyDevicesList[index]);
              },
              title: Text(
                nearbyDevicesList[index].name.toString(),
//                nearbyDevicesList[index].name.toString(),
              ),
            ),
          );
        });
  }

  Widget availableServicesListWidget() {
    print('displaying available services');
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: this.nearbyDevices.length,
        itemBuilder: (context, index) {
          List<BluetoothDevice> nearbyDevicesList = this.nearbyDevices.toList();
          return Card(
            child: ListTile(
              onTap: () {
                print(
                    'device is already connected: ${this.connectedDevice.name}');
                this.printService(index);
                printAvailableCharacteristics();
              },
              title: Text(
                this.availableServices[index].toString(),
              ),
            ),
          );
        });
  }

  void connectToDevice(BluetoothDevice device) async {
    print('connecting to device');
    await device.connect();
    this.connectedDevice = device;
    print('connected to device');
    this.updateAvailableServices();
  }

  void printService(int index) async {
    print('printing service now:');
    BluetoothService service = this.availableServices[index];
    print('services are $service');
    print('service characteristics:');
    var characteristics = service.characteristics;
    for(BluetoothCharacteristic c in characteristics) {
      List<int> value = await c.read();
      print(value);
    }
  }

  Widget appropriateBluetoothList() {
    switch (this.btDisplayNum) {
      case 0:
        return Text(
          'loading...',
          style: TextStyle(fontSize: 18.0),
        );
        break;
      case 1:
        return Container(height: 500.0, child: this.nearbyDevicesListWidget());
        break;
      case 2:
        return Container(
            height: 500.0, child: this.availableServicesListWidget());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: () {
              print('button was pressed');
              this.updateNearbyDevices();
            },
            child: Icon(Icons.bluetooth),
          ),
          RaisedButton(
            onPressed: () {
              print(this.nearbyDevices);
              setState(() {
                this.btDisplayNum = 1;
              });
            },
            child: Text('print nearby devices'),
          ),
          this.appropriateBluetoothList(),
        ],
      ),
    );
  }
}
