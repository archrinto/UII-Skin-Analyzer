import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../helpers/functions.dart';
import './calendar_widget.dart';
import '../analysis/analysis_result_widget.dart';
import '../../models/analysis_history.dart';

class JerawatHistoryScreen extends StatelessWidget {
  JerawatHistoryScreen({super.key, required this.analysisHistory, required this.selectedAnalysisHistory});

  static const routeName = '/jerawat-history';

  final List<AnalysisHistory> analysisHistory;
  final List<AnalysisHistory> selectedAnalysisHistory;

  final ValueNotifier<List> _selectedEvent = ValueNotifier([]);

  void _onChangeDate(DateTime selectedDay, List<AnalysisHistory> Function(DateTime) getEventForDay) {
    _selectedEvent.value = getEventForDay(selectedDay);
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
          'Riwayat Hasil Analisis',
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              CalendarWidget(
                analysisHistory: analysisHistory,
                onChangeDate: _onChangeDate,
                calendarFormat: CalendarFormat.week,
                header: false,
                date: DateTime.parse(selectedAnalysisHistory[0].date),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<List>(
                valueListenable: _selectedEvent,
                builder: (ctx, value, _) {
                  return (value.isEmpty)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: [
                              Lottie.asset('assets/lotties/empty.json'),
                              const Text(
                                'Anda tidak menyimpan hasil analisis pada hari ini',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      : AnalysisResultWidget(
                          strokeWidth: 3,
                          notificationMessage: 'Terdeteksi ${generateJerawats(value[0].jerawatResult!).length} Jerawat',
                          imageFile: File(value[0].imagePath),
                          objectData: generateJerawats(value[0].jerawatResult!),
                          canvasColor: const Color(0xff1572A1),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
