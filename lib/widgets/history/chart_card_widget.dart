import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/history/chart_widget.dart';
import '../../models/analysis_history.dart';

class ChartCardWidget extends StatefulWidget {
  const ChartCardWidget({super.key, required this.analysisHistory});

  final List<AnalysisHistory> analysisHistory;

  @override
  State<ChartCardWidget> createState() => _ChartCardWidgetState();
}

class _ChartCardWidgetState extends State<ChartCardWidget> {
  String selectedMonth = DateFormat.MMMM('id_ID').format(DateTime.now());
  String selectedType = 'Jerawat';

  List<AnalysisHistory> filteredAnalysisHistory = [];

  final List<DropdownMenuItem<String>> _monthItems = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  final List<DropdownMenuItem<String>> _typeItems = <String>[
    'Jerawat',
    'Kemerahan',
    'Keriput',
    'Bercak Hitam',
  ].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  Widget _buildDropdown(String dropdownType, String value, Icon icon, List<DropdownMenuItem<String>> items) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          alignment: Alignment.center,
          onChanged: (newValue) {
            setState(() {
              if (dropdownType == 'month') {
                selectedMonth = newValue!;
                filteredAnalysisHistory =
                    widget.analysisHistory.where((obj) => DateFormat.MMMM('id_ID').format(DateTime.parse(obj.date)) == newValue).toList();
              }
              // if (dropdownType == 'type') {
              //   selectedType = newValue!;
              // }
            });
          },
          icon: icon,
          value: value,
          items: items,
        ),
      ),
    );
  }

  @override
  void initState() {
    filteredAnalysisHistory = widget.analysisHistory.where((obj) => DateTime.parse(obj.date).month == DateTime.now().month).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.only(left: 10, top: 20, bottom: 18, right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown('month', selectedMonth, const Icon(Icons.calendar_month_outlined), _monthItems),
              _buildDropdown('type', selectedType, const Icon(Icons.face_outlined), _typeItems),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
            child: Text(
              'Grafik $selectedType Pada Bulan $selectedMonth',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.75,
            child: ChartWidget(analysisHistory: filteredAnalysisHistory),
          ),
        ],
      ),
    );
  }
}
