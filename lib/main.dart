import 'dart:convert';

import 'package:attendancetest1/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'functions/crypto.dart';
import 'screens/read_example_screen.dart';
import 'screens/write_example_screen.dart';
import 'package:random_string/random_string.dart';
import 'dart:developer';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

void main() {
  print(encryptStringWithXORtoHex(
      "Kevin Antony/pre-k/${DateFormat('HH-mm-ss').format(DateTime.now())}",
      KEY));
  print(decryptStringWithXORFromHex(
      "280a065d576f715a001b0b174b111c06485c4a434c4e5d44190979", KEY));
  runApp(ExampleApp());
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int numOfIds = 100;
  List<String> idList;

  String generateAlpha() {
    return randomAlphaNumeric(8);
  }

  void generateIds() {
    idList = List.generate(numOfIds, (index) => generateAlpha());
  }

  void checkDuplicates() {
    while (idList.length != numOfIds) {
      idList.toSet();
      debugPrint('${idList.length}');
      for (var i = 0; i < numOfIds - idList.length; i++) {
        idList.add(generateAlpha());
      }
    }
  }

  @override
  void initState() {
    generateIds();
    checkDuplicates();
    super.initState();
  }

  List<String> grades = [
    "pre-k",
    "kindergarten",
    "first",
    "second",
    "third",
    "fourth",
    "fifth",
    "sixth",
    "seventh",
    "eighth",
    "ninth",
    "tenth",
    "eleventh",
    "twelfth"
  ];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text("NFC in Flutter examples"),
          ),
          body: ListView(
            children: <Widget>[
              ListTile(
                title: const Text("Read NFC"),
                onTap: () {
                  Get.to(ReadExampleScreen(
                    id: idList,
                    grades: grades,
                  ));
                },
              ),
              ListTile(
                title: const Text("Write NFC"),
                onTap: () {
                  Get.to(WriteExampleScreen(
                    ids: idList,
                    grades: grades,
                  ));
                },
              ),
            ],
          )),
      routes: {
        "/read_example": (context) => ReadExampleScreen(
              id: idList,
            ),
        "/write_example": (context) => WriteExampleScreen(),
      },
    );
  }
}
