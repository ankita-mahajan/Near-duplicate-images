import 'dart:io';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:imgs/models/models.dart';

class DuplicateCountProvider extends GetxController {
  int exactDuplicateCount = 0;
  int nearDuplicateCount = 0;

  List<File> files = [];
  List<MyFileModel> shortListedFiles = [];
  List<MyFileModel> duplicateFilesList = [];
  List<MyFileModel> result = [];
  List<String> hashedFiles = [];

  incrementExact() => exactDuplicateCount++;

  incrementNear() => nearDuplicateCount++;

  addDupInList(MyFileModel file) => duplicateFilesList.add(file);

  refreshScreen() {
    result = LinkedHashSet<MyFileModel>.from(duplicateFilesList).toList();
    update();
  }
}
