import 'package:flutter/material.dart';

import 'dart:io';

import 'package:getaqi/features/sensor_read/sensorController.dart';
import 'package:path_provider/path_provider.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  String fileData = "";

  Future<void> readFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sensor_log.txt');

    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        fileData = contents;
      });
    } else {
      setState(() {
        fileData = "File not found at ${file.path}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sensor Logger")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => SensorServiceController.start(),
            child: const Text("Start Logging"),
          ),
          ElevatedButton(
            onPressed: () => SensorServiceController.stop(),
            child: const Text("Stop Logging"),
          ),
          ElevatedButton(onPressed: readFile, child: const Text("Read File")),
          ElevatedButton(
            onPressed: () async {
              await SensorServiceController.delete();
              setState(() {
                fileData = "File Deleted";
              });
            },
            child: const Text("Delete File"),
          ),
          Expanded(child: SingleChildScrollView(child: Text(fileData))),
        ],
      ),
    );
  }
}
