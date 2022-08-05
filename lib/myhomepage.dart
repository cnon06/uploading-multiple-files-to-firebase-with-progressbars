import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String fileString = "";
  String fileName = "";
  double? _progress;
  UploadTask? uploadTask;
  String? uploadingFile;
  List<File>? files;
  Map<String?, double?>? progressesOfFiles;

 

  @override
  void initState() {
  progressesOfFiles = {null: null};
  
    super.initState();
  }

  void uploadTaskProgress() {
    uploadTask!.snapshotEvents.listen((event) {
      setState(() {
       
        uploadingFile = event.ref.fullPath;
        _progress =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        progressesOfFiles![uploadingFile] = _progress;
        
      });
      if (event.state == TaskState.success) {
        _progress = null;
        uploadingFile = null;
        
      }
    }).onError((error) {
      // do something to handle error
    });
  }

  void putFile() async {
    progressesOfFiles?.clear();

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();

      //for (int i = 0; i < files!.length; i++)
      for (var file1 in files!)
      {
        String fileName = file1 //files![i]
            .path
            .toString()
             .substring(file1.path.lastIndexOf("/") + 1);
            //.substring(files![i].path.lastIndexOf("/") + 1);
       
        final ref = FirebaseStorage.instance.ref().child(fileName);

        

      //  print(progressesOfFiles);

        

      //  uploadTask = ref.putFile(files![i]);
         uploadTask = ref.putFile(file1);
        uploadTaskProgress();
      }
    } else {}

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            progressesOfFiles?.keys.length != null
                ? SizedBox(
                    height: 400,
                    child: ListView.builder(
                        itemCount: progressesOfFiles?.keys.length,
                        itemBuilder: (context, index) {
                          List<String?> keys = progressesOfFiles!.keys.toList();

                          return keys[index] != null ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "${keys[index]} : %${(progressesOfFiles![keys[index]]!*100).round() } "),
                                  
                                 
                          
                                  SizedBox(
                                            width: 100,
                                            child: LinearProgressIndicator(
                                              value: progressesOfFiles![keys[index]], //controller.value,
                                              semanticsLabel: 'Linear progress indicator',
                                            ),
                                          )
                          
                            ],
                          )  : Center(child: const Text("There is no data"));
                         
                        }),
                  )
                : const Text("select files pls"),
            _progress != null
                ? SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _progress, //controller.value,
                      semanticsLabel: 'Linear progress indicator',
                    ),
                  )
                : const SizedBox(height: 10),
            Text(
                "Progress: %${_progress != null ? (_progress! * 100).round() : _progress}"),
            Text("File: $uploadingFile"),
            TextButton(
                onPressed: () {
                  putFile();
                },
                child: const Text("File")),
          ],
        ),
      ),
    );
  }
}
