import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class ReadExampleScreen extends StatefulWidget {
  @override
  _ReadExampleScreenState createState() => _ReadExampleScreenState();
}

class _ReadExampleScreenState extends State<ReadExampleScreen> {
  bool nfcState = false;
  String currentMessage = '';
  StreamSubscription<NDEFMessage> _stream;

  //Funciton to start scanning, changes the ui to indicate scanning and upon successful read of an nfc tag will display the message in the ui
  void _startScanning() {
    setState(() {
      nfcState = true;
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) async {
        print("Read NDEF message with ${message.records.length} records");
        var record = message.records[0];
        print("Record data: '${record.data}'");
        setState(() {
          currentMessage = record.data;
        });
        NFC
            .writeNDEF(NDEFMessage.withRecords(
                [NDEFRecord.type('text/plain', currentMessage)]))
            .first;
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
  void _toggleScan() {
    if (_stream == null) {
      _startScanning();
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
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NFC is ' + (nfcState ? "on" : "off"),
            style: TextStyle(fontSize: 30),
          ),
          ElevatedButton(
            child: const Text("Toggle scan"),
            onPressed: _toggleScan,
          ),
          Text(
            'Current message is:\n ${currentMessage.isNotEmpty ? currentMessage : "\"empty\""}',
            style: TextStyle(
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )),
    );
  }
}
