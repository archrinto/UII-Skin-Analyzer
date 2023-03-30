import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import './analysis_result_widget.dart';
import '../../helpers/json.dart';
import '../../models/deteksi_model.dart';

class KeriputAnalysisScreen extends StatefulWidget {
  const KeriputAnalysisScreen({super.key});

  static const routeName = '/keriput-screen';

  @override
  State<KeriputAnalysisScreen> createState() => _KeriputAnalysisScreenState();
}

class _KeriputAnalysisScreenState extends State<KeriputAnalysisScreen> {
  File? _imageFile;
  List<DeteksiModel> _keriputData = [];
  int _keriputCount = 0;
  bool _isServerError = false;
  bool _isUploadingImage = false;

  Future<void> getFileData(String path) async {
    final byteData = await rootBundle.load('assets/images/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

    setState(() {
      _imageFile = File(file.path);
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploadingImage = true;
    });

    File convertedImage = File(_imageFile!.path);
    var count = 0;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://192.168.100.13:5000/deteksi_keriput"),
    );
    request.files.add(
      http.MultipartFile(
        'file[]',
        convertedImage.readAsBytes().asStream(),
        convertedImage.lengthSync(),
        filename: convertedImage.path,
      ),
    );

    try {
      var res = await request.send();
      http.Response response = await http.Response.fromStream(res);

      var jsonData = json.decode(response.body);
      JSONResult sample = JSONResult.fromJson(jsonData[0]);

      for (int i = 0; i < sample.deteksiObjek!.keriput!.length; i++) {
        count++;
      }

      setState(() {
        _isUploadingImage = false;
        _isServerError = false;
        _keriputData = [...(sample.deteksiObjek!.keriput)!];
        _keriputCount = count;
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
        _isServerError = true;
        _keriputData = [];
        _keriputCount = 0;
      });
    }
  }

  void _pickImage(int index, BuildContext context) {}

  @override
  void initState() {
    getFileData('keriput.png');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Keriput',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(
              Icons.help,
              color: Colors.amber,
              size: 36,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEFF5FF),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AnalysisResultWidget(
          strokeWidth: 2,
          isServerError: _isServerError,
          notificationMessage: 'Terdeteksi $_keriputCount Keriput',
          imageFile: _imageFile,
          objectData: _keriputData,
          canvasColor: Colors.red,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 24,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        onTap: _isUploadingImage
            ? null
            : (value) {
                _pickImage(value, context);
              },
        items: const [
          BottomNavigationBarItem(
            label: 'Galeri',
            icon: ImageIcon(
              AssetImage(
                'assets/images/icons/gallery.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Kamera',
            icon: ImageIcon(
              AssetImage(
                'assets/images/icons/camera.png',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF0E6CDB),
            onPressed: (_isUploadingImage)
                ? null
                : () async {
                    await _uploadImage();
                  },
            child: _isUploadingImage
                ? const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Image.asset(
                          'assets/images/icons/analyze.png',
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      const Text(
                        'Analisis',
                        style: TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
