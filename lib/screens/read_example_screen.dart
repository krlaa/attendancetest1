import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:attendancetest1/models/student_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:http/http.dart' as http;

Future sendChange(Map now) async {
  var res = await http
      .post(Uri.tryParse("https://tzzu7v.deta.dev/takeAttendance"), body: {
    "id": now["id"],
    "secret": now["newSecret"],
    "time": now["currentTime"].toIso8601String()
  });
  return res.statusCode;
}

class ReadExampleScreen extends StatefulWidget {
  final List id;
  final grades;

  const ReadExampleScreen({this.id, this.grades}) : super();
  @override
  _ReadExampleScreenState createState() => _ReadExampleScreenState();
}

class _ReadExampleScreenState extends State<ReadExampleScreen> {
  Map studentList;
  int currentIndex = 0;
  bool nfcState = false;
  String currentMessage = '';
  StreamSubscription<NDEFMessage> _stream;
  Future students;
  Future fetchCurrents() async {
    var response = await http.get(Uri.tryParse(
        "https://assembly-52-default-rtdb.firebaseio.com/students/.json"));
    Map json = jsonDecode(response.body);
    return [json, json.values.map((e) => Student.fromMap(e)).toList()];
  }

  @override
  void initState() {
    students = fetchCurrents();

    // TODO: implement initState
    super.initState();
  }

  //Funciton to start scanning, changes the ui to indicate scanning and upon successful read of an nfc tag will display the message in the ui
  void _startScanning(id) {
    setState(() {
      nfcState = true;
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) async {
        print("Read NDEF message with ${message.records.length} records");
        print(message.tag.id);
        var record = message.records[0];
        print(record.data.split("_"));
        var uuid = record.data.split('_')[1];
        var secret = record.data.split('_')[0];
        print("Record data: '${record.data}'");
        if (studentList.keys.contains(uuid)) {
          if (secret == studentList[uuid]["currentSecret"]) {
            setState(() {
              currentMessage =
                  "Old: ${record.data}\nIndex: $currentIndex\nNew: ${id[currentIndex]}";
            });
            message.tag.write(NDEFMessage.withRecords(
                [NDEFRecord.type('text/plain', "${id[currentIndex]}_$uuid")]));
            studentList[uuid]["currentSecret"] = id[currentIndex];
            compute(
                sendChange,
                Map.from({
                  "currentTime": DateTime.now(),
                  "id": uuid,
                  "newSecret": id[currentIndex]
                }));
            if (record.data != '') {
              currentIndex += 1;
            }
          } else {
            setState(() {
              currentMessage = "Wrong secret cloned tag detected";
            });
          }
        } else {
          setState(() {
            currentMessage = "Error";
          });
        }
      }, onError: (error) {
        print("ERRORs");
        if (error is NFCUserCanceledSessionException) {
          print("user canceled");
        } else if (error is NFCSessionTimeoutException) {
          print("session timed out");
        } else {
          print("error: $error");
        }
      }, onDone: () async {
        await Future.delayed(Duration(seconds: 1));

        setState(() {
          _stream = null;
        });
      });
    });
  }

  //Funciton to stop scanning this also updates the UI to say that the app is currently not scanning.
  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      nfcState = false;
      _stream = null;
    });
  }

  //Simple toggle to start and stop the nfc stream
  void _toggleScan(id) {
    if (_stream == null) {
      _startScanning(id);
    } else {
      _stopScanning();
    }
  }

  //Function to dispose the screen as well as the NFC stream
  @override
  void dispose() {
    super.dispose();
    _stopScanning();
  }

  // Below is the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Read NFC example"),
      ),
      body: FutureBuilder(
          future: students,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              studentList = snapshot.data[0];
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NFC is ' + (nfcState ? "on" : "off"),
                    style: TextStyle(fontSize: 30),
                  ),
                  ElevatedButton(
                    child: const Text("Toggle scan"),
                    onPressed: () => _toggleScan(widget.id),
                  ),
                  Text(
                    'Current message is:\n ${currentMessage.isNotEmpty ? currentMessage : "\"empty\""}',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ));
            }
          }),
    );
  }
}
