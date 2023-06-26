import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../helpers/db.dart';
import '../../models/analysis_history.dart';
import './chart_card_widget.dart';
import './calendar_card_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  List<AnalysisHistory> _analysisHistory = [];

  bool isFetching = false;

  Future<void> fetchAndSetAnalysisHistory() async {
    if (auth.currentUser == null) {
      return;
    }

    setState(() {
      isFetching = true;
    });

    final rawData = await DBHelper.getData('analysis_results');

    List<AnalysisHistory> rawAnalysisHistory = rawData
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

    _analysisHistory = rawAnalysisHistory
        .where((obj) => obj.email == auth.currentUser!.email)
        .toList();

    setState(() {
      isFetching = false;
    });
  }

  @override
  void initState() {
    fetchAndSetAnalysisHistory();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return auth.currentUser == null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Lottie.asset('assets/lotties/empty.json'),
                const Text(
                  'Silakan masuk untuk dapat melihat hasil analisis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
        : isFetching
            ? SizedBox(
                height: MediaQuery.of(context).size.height - 56,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  CalendarCardWidget(analysisHistory: _analysisHistory),
                  ChartCardWidget(analysisHistory: _analysisHistory),
                ],
              );
  }
}
