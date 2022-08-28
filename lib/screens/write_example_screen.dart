import 'package:attendancetest1/functions/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class RecordEditor {
  String grade;
  TextEditingController name;

  RecordEditor() {
    grade = "pre-k";
    name = TextEditingController();
  }
}

class WriteExampleScreen extends StatefulWidget {
  final ids;
  final students;
  final List<String> grades;

  const WriteExampleScreen({Key key, this.ids, this.students, this.grades})
      : super(key: key);

  @override
  _WriteExampleScreenState createState() => _WriteExampleScreenState();
}

class _WriteExampleScreenState extends State<WriteExampleScreen> {
  StreamSubscription<NDEFMessage> _stream;
  List<RecordEditor> _records = [];
  bool _hasClosedWriteDialog = false;
  int currentIndex = 50;
  String currentMessage = '';

  void _addRecord() {
    setState(() {
      _records.add(RecordEditor());
    });
  }

  void _write(BuildContext context) async {
    print(encryptStringWithXORtoHex(
        "${_records.first.name.text}/${_records.first.grade}/${DateTime.now().toIso8601String()}",
        KEY));
    var uuid = Uuid();

    String userId = encryptStringWithXORtoHex(
        "${_records.first.name.text}/${_records.first.grade}/${DateFormat('HH-mm-ss').format(DateTime.now())}",
        KEY);
    Get.defaultDialog(
        title: "Uploading",
        content: Center(
          child: CircularProgressIndicator(),
        ));
    var response = await http
        .post(Uri.tryParse("https://tzzu7v.deta.dev/createStudent"), body: {
      "name": _records.first.name.text,
      "grade": _records.first.grade,
      "id": userId,
      "currentSecret": widget.ids[currentIndex]
    });
    print(response.statusCode);
    Get.back();
    List<NDEFRecord> records = _records.map((record) {
      return NDEFRecord.type(
        'text/plain',
        '${widget.ids[currentIndex]}_$userId',
      );
    }).toList();
    NDEFMessage message = NDEFMessage.withRecords(records);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scan the tag you want to write to"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              _hasClosedWriteDialog = true;
              _stream?.cancel();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    print(message.payload);
    // Write to the first tag scanned
    await NFC.writeNDEF(message).first;
    //close the dialog
    setState(() {
      currentMessage = "Index: $currentIndex\nNew: ${widget.ids[currentIndex]}";
    });
    currentIndex += 1;
    Navigator.pop(context);
  }

  //Below is the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write NFC example"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
              child: OutlinedButton(
            child: const Text("Add record"),
            onPressed: _records.length < 1 ? _addRecord : null,
          )),
          for (var record in _records)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Record", style: Theme.of(context).textTheme.body2),
                  TextFormField(
                    controller: record.name,
                    decoration: InputDecoration(
                      hintText: "Name",
                    ),
                  ),
                  DropdownButton<String>(
                    focusColor: Colors.white,
                    value: record.grade,
                    //elevation: 5,
                    style: TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.black,
                    items: widget.grades
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    hint: Text(
                      "Please choose a langauage",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        record.grade = value;
                      });
                    },
                  )
                ],
              ),
            ),
          Center(
            child: ElevatedButton(
              child: const Text("Write to tag"),
              onPressed: _records.length > 0 ? () => _write(context) : null,
            ),
          ),
          Text(
            'Current message is:\n ${currentMessage.isNotEmpty ? currentMessage : "\"empty\""}',
            style: TextStyle(
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
