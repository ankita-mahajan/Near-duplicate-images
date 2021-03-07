import 'package:get/get.dart';
import 'package:flutter/material.dart';

import './screens/screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Duplicate Image Finder',
      home: HomeScreen(),
    );
  }
}
