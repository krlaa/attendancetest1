import 'package:flutter/material.dart';
import 'screens/read_example_screen.dart';
import 'screens/write_example_screen.dart';
import 'package:random_string/random_string.dart';
import 'package:random_string/random_string.dart';

void main() => runApp(ExampleApp());

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
    print(idList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("NFC in Flutter examples"),
        ),
        body: Builder(builder: (context) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: const Text("Read NFC"),
                onTap: () {
                  Navigator.pushNamed(context, "/read_example");
                },
              ),
              ListTile(
                title: const Text("Write NFC"),
                onTap: () {
                  Navigator.pushNamed(context, "/write_example");
                },
              ),
            ],
          );
        }),
      ),
      routes: {
        "/read_example": (context) => ReadExampleScreen(),
        "/write_example": (context) => WriteExampleScreen(),
      },
    );
  }
}
