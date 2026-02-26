import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

Uint8List decodeBase64(String base64Str) {
  return base64Decode(base64Str); // heavy task
}

Uint8List processImage(Map<String, dynamic> data) {
  Uint8List bytes = data['bytes'];
  int width = data['width'];
  int height = data['height'];
  // Decode and resize the image (heavy task)
  img.Image? image = img.decodeImage(bytes);
  img.Image resized = img.copyResize(image!, width: width, height: height);
  return Uint8List.fromList(img.encodePng(resized));
}

class Base64ImageDemo extends StatefulWidget {
  final String base64Str;
  Base64ImageDemo({required this.base64Str});

  @override
  _Base64ImageDemoState createState() => _Base64ImageDemoState();
}

class _Base64ImageDemoState extends State<Base64ImageDemo> {
  Uint8List? imageBytes;
  final Width = TextEditingController();
  final Height = TextEditingController();
  XFile? file;

  @override
  void initState() {
    super.initState();
    decodeImage();
  }

  void decodeImage() async {
    Uint8List bytes = await compute(processImage, {
      "bytes": imageBytes ?? decodeBase64(widget.base64Str),
      "width": int.parse(Width.text),
      "height": int.parse(Height.text),
    });
    setState(() {
      imageBytes = bytes;
    });
  }

  void pickImage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        file = result;
        file!.readAsBytes().then((bytes) {
          imageBytes = bytes;
          file = null; // Clear file to show processed image
        });
      });
    }
  }

  Future<String> saveImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/processed_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Process")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: Text("Select Image"),
                ),
                TextField(
                  controller: Width,
                  decoration: InputDecoration(labelText: "Width"),
                ),
                TextField(
                  controller: Height,
                  decoration: InputDecoration(labelText: "Height"),
                ),
                ElevatedButton(
                  onPressed: () {
                    decodeImage();
                  },
                  child: Text("Convert"),
                ),

                file != null
                    ? Image.file(File(file!.path))
                    : imageBytes != null
                    ? Image.memory(imageBytes!)
                    : CircularProgressIndicator(),

                if (imageBytes != null)
                  ElevatedButton(
                    onPressed: () async {
                      if (imageBytes != null) {
                        // String path = await saveImage(imageBytes!);

                        await GallerySaver.saveImage(imageBytes!);

                        //  print("Saved at: $path");
                      }
                    },
                    child: Text("Save"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GallerySaver {
  static const platform = MethodChannel("sensor_service_channel");

  static Future<void> saveImage(Uint8List bytes) async {
    await platform.invokeMethod("saveImage", bytes);
  }
}
