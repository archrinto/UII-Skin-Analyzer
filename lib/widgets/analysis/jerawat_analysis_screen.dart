import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import './analysis_result_widget.dart';
import '../utility/dialog_widget.dart';
import '../utility/camera_screen.dart';
import '../../helpers/db.dart';
import '../../helpers/json.dart';
import '../../models/deteksi_model.dart';
import '../../widgets/main_screen.dart';

class JerawatAnalysisScreen extends StatefulWidget {
  const JerawatAnalysisScreen({super.key});

  static const routeName = '/jerawat-screen';

  @override
  State<JerawatAnalysisScreen> createState() => _JerawatAnalysisScreenState();
}

class _JerawatAnalysisScreenState extends State<JerawatAnalysisScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  File? _imageFile;
  List<DeteksiModel> _jerawatData = [];
  int _jerawatCount = 0;
  bool _isServerError = false;
  bool _isUploadingImage = false;

  Future<void> _cachingImage(XFile imageFile) async {
    if (_imageFile != null) {
      await _imageFile!.delete();
      _imageFile = null;
    }

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final finalPath = '${appDir.path}/$fileName';

    File? convertedFile = File(imageFile.path);
    File? savedImage = await convertedFile.copy(finalPath);

    await convertedFile.delete();
    convertedFile = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedImage', savedImage.path);

    setState(() {
      _imageFile = savedImage;
      _isServerError = false;
      _isUploadingImage = false;
      _jerawatData = [];
      _jerawatCount = 0;
    });
  }

  Future<void> _fetchCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('cachedImage');
    if (imagePath == null) {
      return;
    }

    setState(() {
      _imageFile = File(imagePath);
    });
  }

  Future<void> _saveToDB() async {
    setState(() {
      _isUploadingImage = true;
    });
    final dateNow = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final date = '${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}';

    final dateFormat = DateFormat.yMd().format(dateNow);
    final jsonData = json.encode(_jerawatData);

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final Directory appDocDirFolder = Directory('${appDir.path}/jerawat_history/');
    final Directory appDocDirNewFolder = await appDocDirFolder.create();

    final fileName = path.basename(_imageFile!.path);
    final finalPath = '${appDocDirNewFolder.path}$fileName$date';

    File savedImage = await _imageFile!.copy(finalPath);

    var searchDay = await DBHelper.getSingleData(
      'analysis_results',
      ['id'],
      '$dateFormat${auth.currentUser!.email!}',
    );

    // CollectionReference users = firestore.collection('users');
    // DocumentReference docRef = users.doc(auth.currentUser!.uid);
    // DocumentSnapshot<Object?> docSnapshot = await docRef.get();
    // Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

    if (searchDay.isNotEmpty) {
      var searchFile = await DBHelper.getSingleData('analysis_results', ['id', 'image_path'], '$dateFormat${auth.currentUser!.email!}');
      var searchedImage = searchFile[0]['image_path'];
      if (searchedImage != savedImage.path && File(searchedImage).existsSync()) {
        File? file = File(searchedImage);
        await file.delete();
        file = null;
      }

      // await users.doc(auth.currentUser!.uid).update({
      //   'jerawatCount': data['jerawatCount'] + _jerawatCount,
      // });
    } else {
      // await users.doc(auth.currentUser!.uid).update({
      //   'jerawatCount': data['jerawatCount'] + _jerawatCount,
      // });
    }

    await DBHelper.insert('analysis_results', {
      'id': '$dateFormat${auth.currentUser!.email!}',
      'email': auth.currentUser!.email!,
      'image_path': savedImage.path,
      'jerawat_result': jsonData,
      'date': dateNow.toString(),
    });

    setState(() {
      _isUploadingImage = false;
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
      Uri.parse("http://192.168.7.138:5000/deteksi_jerawat"),
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

      for (int i = 0; i < sample.deteksiObjek!.jerawat!.length; i++) {
        if (sample.deteksiObjek!.jerawat![i].score! > 0.3) {
          count++;
        }
      }

      setState(() {
        _isUploadingImage = false;
        _isServerError = false;
        _jerawatData = [...(sample.deteksiObjek!.jerawat)!];
        _jerawatCount = count;
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
        _isServerError = true;
        _jerawatData = [];
        _jerawatCount = 0;
      });
    }
  }

  void _pickImage(int index, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    XFile? imageFile;

    if (index == 0) {
      imageFile = await picker.pickImage(source: ImageSource.gallery);
    } else if (index == 1) {
      imageFile = await Navigator.push<XFile>(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
    }

    if (imageFile == null) {
      return;
    }

    _cachingImage(imageFile);
  }

  void _onPressHelpButton() {
    buildDialog(
      context: context,
      title: 'Panduan Analisis',
      content: RichText(
        text: TextSpan(children: [
          const TextSpan(
              text: 'Galeri ',
              style: TextStyle(
                color: Colors.black,
                height: 1.5,
              )),
          WidgetSpan(
            child: Image.asset(
              'assets/images/icons/gallery.png',
              width: 15,
            ),
          ),
          const TextSpan(
              text: ': Tombol ini berfungsi untuk memilih gambar pada galeri\n\n',
              style: TextStyle(
                color: Colors.black,
                height: 1.5,
              )),
          const TextSpan(
              text: 'Kamera ',
              style: TextStyle(
                color: Colors.black,
                height: 1.5,
              )),
          WidgetSpan(
            child: Image.asset(
              'assets/images/icons/camera.png',
              width: 15,
            ),
          ),
          const TextSpan(
              text: ': Tombol ini berfungsi untuk mengambil gambar dari kamera\n\n',
              style: TextStyle(
                color: Colors.black,
                height: 1.5,
              )),
          const TextSpan(
              text: 'Analisis ',
              style: TextStyle(
                color: Colors.black,
                height: 1.5,
              )),
          WidgetSpan(
            child: Image.asset(
              'assets/images/icons/analyze.png',
              width: 15,
            ),
          ),
          const TextSpan(
              text: ': Tombol ini berfungsi untuk menganalisis gambar yang sudah terpilih baik itu melalui galeri maupun kamera\n',
              style: TextStyle(
                color: Colors.black,
                height: 1.5,
              )),
        ]),
      ),
      actionButton: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: buildActionButton(context, 'Tutup'),
        ),
      ],
    );
  }

  Widget _saveImageButton() {
    return _jerawatData.isNotEmpty
        ? Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: 40,
              height: 40,
              child: ElevatedButton(
                onPressed: _isUploadingImage
                    ? null
                    : () {
                        if (auth.currentUser == null) {
                          buildDialog(
                            context: context,
                            title: 'Pesan',
                            content: const Text(
                              'Untuk menyimpan hasil analisis, anda harus masuk terlebih dahulu. Hasil analisis beserta detailnya hanya dapat diakses oleh perangkat anda saja.',
                              textAlign: TextAlign.justify,
                            ),
                            actionButton: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();

                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)));
                                },
                                child: buildActionButton(context, 'Masuk'),
                              ),
                            ],
                          );
                        } else {
                          _saveToDB();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6CDB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(0),
                  disabledBackgroundColor: const Color(0xFF0E6CDB),
                  disabledForegroundColor: Colors.white,
                ),
                child: const Icon(Icons.save),
              ),
            ),
          )
        : const SizedBox();
  }

  @override
  void initState() {
    _fetchCachedImage();

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
          'Jerawat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              onPressed: _onPressHelpButton,
              icon: const Icon(
                Icons.help,
                color: Colors.amber,
                size: 36,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEFF5FF),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AnalysisResultWidget(
          strokeWidth: 3,
          isServerError: _isServerError,
          imageFile: _imageFile,
          objectData: _jerawatData,
          notificationMessage: 'Terdeteksi $_jerawatCount Jerawat',
          saveResultButton: _saveImageButton(),
          canvasColor: const Color(0xff1572A1),
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
            backgroundColor: _imageFile == null ? Colors.grey : const Color(0xFF0E6CDB),
            onPressed: (_imageFile == null || _isUploadingImage)
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
