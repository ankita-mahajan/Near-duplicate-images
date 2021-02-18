import 'package:flutter/material.dart';

import './my_file_model.dart';

import '../providers/providers.dart';

class DuplicateFile {
  final String name;
  final int startIndex;
  final int endIndex;
  final List<MyFileModel> files;
  // final DuplicateCountController controller;

  DuplicateFile({
    @required this.name,
    @required this.startIndex,
    @required this.endIndex,
    @required this.files,
    // @required this.controller,
  });
}
