import 'dart:typed_data';
import 'package:flutter/material.dart';

class MyFileModel {
  final String path;
  final String name;
  final Uint8List bytes;
  final DateTime modifiedTime;

  MyFileModel({
    @required this.path,
    @required this.name,
    @required this.bytes,
    @required this.modifiedTime,
  });
}
