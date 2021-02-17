import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'difference_hash.dart';
import 'package:image/image.dart'
    as imageLib; // Naming conflict with internal Image color class
import 'package:http/http.dart' as http;
//import package files

void main() => runApp(MyApp());

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
  List files;
  List<Uint8List> hashfiles = new List<Uint8List>();
  bool noFiles = false;
  List<dynamic> duplicateFiles = new List<dynamic>();
  void getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0]
        .rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root)); //
    files = await fm.filesTree(
        excludedPaths: ["/storage/emulated/0/Android/"],
        extensions: ["jpg"] //optional, to filter files, list only pdf files
        );
    DateTime todaysDate = DateTime.now();
    DateTime duration = todaysDate.subtract(Duration(days: 1));
    int count = 0;

    for (int i = 0; i < files.length; i++) {
      DateTime lastModifiedTime = await files[i].lastModified();
      if (lastModifiedTime.isAfter(duration) &&
          lastModifiedTime.isBefore(todaysDate)) {
        final bytes = await files[i].readAsBytes();
        hashfiles.add(bytes);
      }
    }

    for (int i = 0; i < hashfiles.length - 1; i++) {
      int difference = DifferenceHash().compare(
          imageLib.decodeImage(hashfiles[i]),
          imageLib.decodeImage(hashfiles[i]));
      if (difference < 5) {
        count++;
      }
    }

    print(count);
    if (duplicateFiles.isEmpty) {
      noFiles = true;
    }

    setState(() {}); //update the UI
  }

  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  var isSelected = false;
  var mycolor = Colors.white;
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
                          title:
                              Text(duplicateFiles[index].path.split('/').last),
                          leading: Icon(Icons.picture_as_pdf),
                        ),
                      );
                    },
                  ));
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
