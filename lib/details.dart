import 'package:ble_scanner/models/scanned_device.dart';
import 'package:flutter/material.dart';

class ScanDetailsPage extends StatelessWidget {
  final ScannedDevice details;

  ScanDetailsPage(this.details);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Device Details"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Device name: ${details.name}"),
              Text("Mac address: ${details.id}"),
              Text("Signal Strength: ${details.rssi} RSSI"),
            ],
          ),
        ));
  }
}
