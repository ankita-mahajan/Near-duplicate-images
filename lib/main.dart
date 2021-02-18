import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:imgs/TodoModel.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'difference_hash.dart';
import 'package:image/image.dart'
    as imageLib; // Naming conflict with internal Image color class
//import package files

import './models/models.dart';
import './providers/providers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => TodoModel(),
        child: MyPDFList(),
      ), //call MyPDF List file
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
  final DuplicateCountController controller =
      Get.put(DuplicateCountController());

  List<File> files;
  List<Uint8List> hashfiles = [];
  Map<String, Uint8List> dupFiles = {};
  bool noFiles = false;
  List<dynamic> duplicateFiles = [];
  int mid = 0;
  List<MyFileModel> shortListedFiles = [];
  var list = [];

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
          // IconButton(
          //   icon: Icon(Icons.delete_forever),
          //   onPressed: isSelected
          //       ? () {
          //           for (int i = 0; i < duplicateFiles.length; i++) {
          //             duplicateFiles[i].delete();
          //           }
          //           setState(() {
          //             getFiles();
          //           });
          //         }
          //       : null,
          // ),
        ],
      ),
      body: Consumer<TodoModel>(
        builder: (context, todo, child) {
          return todo.taskList.isEmpty
              ? Center(child: Text("Searching Files.."))
              : Container(
                  margin: EdgeInsets.all(8.0),
                  child: StaggeredGridView.countBuilder(
                    itemCount: todo.taskList.length,
                    crossAxisCount: 4,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      String imgPath =
                          "https://ia-discourse.s3-us-west-1.amazonaws.com/original/2X/9/97d457372f6c14182b686ecfdf5d4067df5e9373.png";
                      if (todo.taskList[index].path != null) {
                        imgPath = todo.taskList[index].path;
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Material(
                            elevation: 8.0,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            shadowColor: Colors.black,
                            child: InkWell(
                              onTap: () {
                                /*Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    new ViewPhotos(imgPath)));
                                      */
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Hero(
                                    tag: imgPath,
                                    child: Image.file(
                                      File(imgPath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  /* Container(
                                        height: 20,
                                        width: 20,
                                        alignment: Alignment.topLeft,
                                        child: Checkbox(
                                          value: list[index],
                                          onChanged: (bool value) {
                                            setState(() {
                                              list[index] = !list[index];
                                            });
                                            print(list[index]);
                                            /* setState(() {
                                        list[index] = value;
                                        print(list[index]);
                                      }); */
                                          },
                                          hoverColor: Colors.red,
                                        ),
                                      ),*/
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    staggeredTileBuilder: (i) =>
                        StaggeredTile.count(2, i.isEven ? 2 : 3),
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                );
        },
      ),
    );
  }

  Future<void> getFiles() async {
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
      DuplicateFile(
        name: 'Thread 1',
        startIndex: 0,
        endIndex: mid,
        files: shortListedFiles,
        // controller: controller,
      ),
    );

    Isolate.spawn(
      findDuplicates,
      DuplicateFile(
        name: 'Thread 2',
        startIndex: mid,
        endIndex: shortListedFiles.length,
        files: shortListedFiles,
        // controller: controller,
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
findDuplicates(DuplicateFile data) {
  DuplicateCountController controller = Get.put(DuplicateCountController());

  // int exactDuplicateCount = 0, nearDuplicateCount = 0;
  for (int i = data.startIndex; i < data.endIndex; i++) {
    for (int j = i + 1; j < data.endIndex; j++) {
      try {
        int difference = DifferenceHash().compare(
            imageLib.decodeImage(data.files[i].bytes),
            imageLib.decodeImage(data.files[j].bytes));
        print('${data.name} $i $j $difference ');
        if (difference == 0) {
          controller.incrementExact();
          // exactDuplicateCount++;
        } else if (difference <= 10 && difference >= 1) {
          controller.incrementNear();
          // nearDuplicateCount++;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  print('${data.name} Exact : ${controller.exactDuplicateCount}');
  print('${data.name} Near : ${controller.nearDuplicateCount}');
}
