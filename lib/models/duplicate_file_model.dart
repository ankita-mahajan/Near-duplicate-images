import 'dart:isolate';

import 'package:flutter/material.dart';

import './my_file_model.dart';

class DuplicateFile {
  final String name;
  final bool isEven;
  final List<MyFileModel> files;
  final SendPort sendPort;

  DuplicateFile({
    @required this.name,
    @required this.isEven,
    @required this.files,
    @required this.sendPort,
  });
}
