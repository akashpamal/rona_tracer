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
import 'package:convert/convert.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'dart:async';
import 'dart:core';

class BluetoothManagerStateless extends StatelessWidget {

  int btDisplayNum = 1; // 0 : loading, 1 : nearbyDevices, 2 : availableServices

  Future<List<BluetoothDevice>> getNearbyDevices() async {
    print('updating nearby devices...');
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    Set<BluetoothDevice> nearbyDevices = HashSet();
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
//        print('${r.device.name} found! rssi: ${r.rssi}');
        if (r.device.name != '') {
//        if (r.device.name != '' || r.rssi >= -80) {
          nearbyDevices.add(r.device);
        }
      }
      // Stop scanning
    }, onDone: () {
      print('done scanning');
    });
    flutterBlue.stopScan();
    return Future.delayed(Duration(seconds: 5), () {
      print('returning nearby devices');
      return nearbyDevices.toList();
    });
  }

  Future<List<BluetoothService>> getAvailableServices(
      BluetoothDevice connectedDevice) async {
    print('available services from connected device:');
    List<BluetoothService> services = await connectedDevice.discoverServices();
//    services.forEach((service) {
//      print('service is: $service');
//    });
    print('would setState here with btDisplayNum = 2');
    return services;
  }

  List<BluetoothCharacteristic> getCharacteristics(BluetoothService service) {
    return service.characteristics;
  }

  void printAvailableCharacteristics(BluetoothService service) async {
    print('available characteristics from connected service:');
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      List<int> value = await c.read();
      print(
          '${c.uuid.toString().toUpperCase().substring(4, 8)} has value ${String.fromCharCodes(value.toList())}');
    }
  }

  Future<BluetoothDevice> connectToDevice(BluetoothDevice device) async {
    print('connecting to device');
    await device.connect();
    print('connected to device');
    return device;
  }

  void printService(BluetoothService service) async {
    print('printing service now:');
    print('services are $service');
    print('service characteristics:');
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      List<int> value = await c.read();
      print(value);
    }
  }

  Future<bool> deviceIsPhone(BluetoothDevice device) async {
    //todo add support for android phones
    await this.connectToDevice(device);
    List<BluetoothService> availableServices =
        await this.getAvailableServices(device);
    for (BluetoothService service in availableServices) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<int> value = await c.read();
//        print(
//            '${c.uuid.toString().toUpperCase().substring(4, 8)} has value ${String.fromCharCodes(value.toList())}');
        if (c.uuid.toString().toUpperCase().substring(4, 8) == '2A24' && String.fromCharCodes(value.toList()).toLowerCase().contains('iphone')) {
          print('this device is a phone');
          return true;
        }
      }
    }
    print('device is not a phone');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('bluetooth manager stateless'),
    );
  }


}
