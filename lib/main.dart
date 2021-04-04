import 'package:ble_scanner/scan_page.dart';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ble Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: ScanPage()),
      color: Colors.white,
    );
  }
}
