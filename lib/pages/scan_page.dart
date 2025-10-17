import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  String? _result;
  bool _loading = false;

  static const platform = MethodChannel('com.aigrove/scan');

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
      });
      await _runModel(_image!);
    }
  }

  Future<void> _runModel(File image) async {
    setState(() {
      _loading = true;
    });
    try {
      final result = await platform.invokeMethod('runModel', {
        'imagePath': image.path,
      });
      setState(() {
        _result = result as String?;
      });
    } on PlatformException catch (e) {
      setState(() {
        _result = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Text('No image selected.'),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
            SizedBox(height: 20),
            _result != null
                ? Text('Result: $_result')
                : Container(),
          ],
        ),
      ),
    );
  }
}
