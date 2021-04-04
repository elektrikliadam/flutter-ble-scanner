import 'dart:async';

import 'package:ble_scanner/details.dart';
import 'package:ble_scanner/models/scanned_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:bluetoothonoff/bluetoothonoff.dart';
import 'package:location/location.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<ScannedDevice> scannedDevices = [];
  bool isScanning = false;
  Location location = new Location();
  Timer _scanTimer = Timer(Duration.zero, () {});

  @override
  void initState() {
    flutterReactiveBle.statusStream.listen((status) {
      handleStatus(status);

      debugPrint(status.toString());
    });
    super.initState();
  }

  handleStatus(BleStatus status) async {
    switch (status) {
      case BleStatus.locationServicesDisabled:
        bool success = await location.requestService();
        if (!success) showError("Location service couldn't be started!");
        break;

      case (BleStatus.unsupported):
        showError("Ble is not supported on this device");
        break;

      case BleStatus.unauthorized:
        showError("BLE usage is not authorized for this app");
        break;

      case BleStatus.poweredOff:
        bool success = await BluetoothOnOff.turnOnBluetooth;
        if (!success) showError("Bluetooth service couldn't be started!");
        break;

      default:
        break;
    }
  }

  Future requestServices() async {
    await BluetoothOnOff.turnOnBluetooth;
    await location.requestService();
  }

  void toggleScan() async {
    await requestServices();

    _scanTimer.cancel();
    if (isScanning) {
      flutterReactiveBle.deinitialize();
    } else {
      scannedDevices.clear();
      flutterReactiveBle.scanForDevices(
          withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
        final foundDevice = scannedDevices.indexWhere((e) => e.id == device.id);
        if (foundDevice < 0)
          scannedDevices.add(ScannedDevice(
              id: device.id, name: device.name, rssi: device.rssi));
        setState(() {});
      }, onError: (Object e, StackTrace s) {
        setState(() {
          isScanning = false;
        });
        _scanTimer.cancel();
        showError(e.toString());
        debugPrint(s.toString());
      });
    }
    setState(() {
      isScanning = !isScanning;
    });
    if (isScanning) {
      _scanTimer.cancel();
      _scanTimer = Timer(Duration(seconds: 120), () => toggleScan());
    }
  }

  showError(String errorText) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Error! $errorText"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ble Scanner'),
          actions: [
            FlatButton(
              child: Text(
                isScanning ? "STOP SCANNING" : "SCAN",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onPressed: () => toggleScan(),
            )
          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, index) => ListTile(
            trailing: Text("${scannedDevices[index].rssi.toString()} RSSI"),
            title: Wrap(spacing: 20, children: [
              Text(scannedDevices[index].name),
              Text(scannedDevices[index].id)
            ]),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => ScanDetailsPage(scannedDevices[index])),
            ),
          ),
          itemCount: scannedDevices.length,
        ));
  }
}
