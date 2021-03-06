import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:imgs/providers/duplicate_count_provider.dart';

import './screens/screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DuplicateCountProvider controller = Get.put(DuplicateCountProvider());
    return GetMaterialApp(
      title: 'Duplicate Image Finder',
      home: HomeScreen(),
    );
  }
}
