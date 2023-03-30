import 'dart:convert';

import './db.dart';
import '../models/analysis_history.dart';
import '../models/deteksi_model.dart';

Future<List<AnalysisHistory>> fetchAndSetAnalysisHistory(String email) async {
  final rawData = await DBHelper.getData('analysis_results');
  return rawData
      .map(
        (data) => AnalysisHistory(
          id: data['id'],
          email: data['email'],
          imagePath: data['image_path'],
          jerawatResult: data['jerawat_result'],
          keriputResult: data['keriput_result'],
          kemerahanResult: data['kemerahan_result'],
          bercakHitamResult: data['bercak_hitam_result'],
          jenisKulitResult: data['jenis_kulit_result'],
          date: data['date'],
        ),
      )
      .toList();
}

List<DeteksiModel> generateJerawats(String rawData) {
  List<DeteksiModel> jerawats = [];
  var decodedJSON = json.decode(rawData);
  for (var i = 0; i < decodedJSON.length; i++) {
    if (decodedJSON[i]['score'] > 0.3) {
      var jerawat = DeteksiModel(
        xmax: decodedJSON[i]['xmax'],
        ymax: decodedJSON[i]['ymax'],
        xmin: decodedJSON[i]['xmin'],
        ymin: decodedJSON[i]['ymin'],
        score: decodedJSON[i]['score'],
      );
      jerawats.add(jerawat);
    }
  }
  return jerawats;
}
