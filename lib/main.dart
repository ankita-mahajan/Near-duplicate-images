import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'difference_hash.dart';
import 'package:image/image.dart'
    as imageLib; // Naming conflict with internal Image color class
//import package files

import './my_file_model.dart';

void main() => runApp(MyApp());

class Duplicate {
  final String name;
  final int startIndex;
  final int endIndex;
  final List<MyFileModel> files;

  Duplicate({
    @required this.name,
    @required this.startIndex,
    @required this.endIndex,
    @required this.files,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPDFList(), //call MyPDF List file
    );
  }
}

//apply this class on home: attribute at MaterialApp()
class MyPDFList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPDFList(); //create state
  }
}

class _MyPDFList extends State<MyPDFList> {
  List<File> files;
  List<Uint8List> hashfiles = [];
  Map<String, Uint8List> dupFiles = {};
  bool noFiles = false;
  List<dynamic> duplicateFiles = [];
  int mid = 0;
  List<MyFileModel> shortListedFiles = [];
  int exactDuplicateCount = 0, nearDuplicateCount = 0;
  var isSelected = false;
  var mycolor = Colors.white;

  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF File list from SD Card"),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: duplicateFiles.isNotEmpty
                ? () {
                    toggleSelection();
                  }
                : null,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: isSelected
                ? () {
                    for (int i = 0; i < duplicateFiles.length; i++) {
                      duplicateFiles[i].delete();
                    }
                    setState(() {
                      getFiles();
                    });
                  }
                : null,
          ),
        ],
      ),
      body: duplicateFiles.isEmpty && noFiles == false
          ? Center(child: Text("Searching Files.."))
          : noFiles
              ? Center(child: Text("No duplicate found"))
              : ListView.builder(
                  //if file/folder list is grabbed, then show here
                  itemCount: duplicateFiles?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        selected: isSelected,
                        title: Text(duplicateFiles[index].path.split('/').last),
                        leading: Icon(Icons.picture_as_pdf),
                      ),
                    );
                  },
                ),
    );
  }

  void getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0]
        .rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root)); //
    files = await fm.filesTree(
        excludedPaths: ["/storage/emulated/0/WhatsApp/"],
        excludeHidden: true,
        extensions: [
          "jpg",
          "png"
        ] //optional, to filter files, list only pdf files
        );
    DateTime todaysDate = DateTime.now();
    DateTime duration = todaysDate.subtract(Duration(days: 4));

    for (int i = 0; i < files.length; i++) {
      DateTime lastModifiedTime = await files[i].lastModified();
      if (lastModifiedTime.isAfter(duration) &&
          lastModifiedTime.isBefore(todaysDate)) {
        final bytes = await files[i].readAsBytes();
        shortListedFiles.add(MyFileModel(
            path: files[i].path,
            name: files[i].path.split("/").last,
            bytes: bytes));
        hashfiles.add(bytes);
      }
    }

    ///printing length of shortlisted images
    print(shortListedFiles.length);
    //calculating mid for splitting the execution in two threads
    mid = (shortListedFiles.length / 2).floor();
    Isolate.spawn(
      findDuplicates,
      Duplicate(
        name: 'Thread 1',
        startIndex: 0,
        endIndex: mid,
        files: shortListedFiles,
      ),
    );

    Isolate.spawn(
      findDuplicates,
      Duplicate(
        name: 'Thread 2',
        startIndex: mid,
        endIndex: shortListedFiles.length,
        files: shortListedFiles,
      ),
    );

    if (duplicateFiles.isEmpty) {
      noFiles = true;
    }

    setState(() {}); //update the UI
  }

  void toggleSelection() {
    setState(() {
      if (isSelected) {
        mycolor = Colors.white;
        isSelected = false;
      } else {
        mycolor = Colors.grey[300];
        isSelected = true;
      }
    });
  }
}

//isolates
findDuplicates(Duplicate data) {
  int exactDuplicateCount = 0, nearDuplicateCount = 0;
  for (int i = data.startIndex; i < data.endIndex; i++) {
    for (int j = i + 1; j < data.endIndex; j++) {
      try {
        int difference = DifferenceHash().compare(
            imageLib.decodeImage(data.files[i].bytes),
            imageLib.decodeImage(data.files[j].bytes));
        print('${data.name} $i $j $difference ');
        // await Future.delayed(Duration(seconds: 2));
        if (difference == 0)
          exactDuplicateCount++;
        else if (difference <= 10 && difference >= 1) nearDuplicateCount++;
      } catch (e) {
        print(e);
      }
    }
  }

  print('${data.name} Exact : $exactDuplicateCount');
  print('${data.name} Near : $nearDuplicateCount');
}
