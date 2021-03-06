import 'dart:typed_data';

import 'package:flutter/material.dart';
import './models/models.dart';

class TodoModel extends ChangeNotifier {
  List<MyFileModel> taskList = [];
  addDupInList(String path, String name, Uint8List bytes) {
    MyFileModel myfilemodel = MyFileModel(path: path, name: name, bytes: bytes);
    taskList.add(myfilemodel);
    notifyListeners();
  }
}
