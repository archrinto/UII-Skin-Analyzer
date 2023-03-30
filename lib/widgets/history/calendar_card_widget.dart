import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import './jerawat_history_screen.dart';
import './calendar_widget.dart';
import '../../models/analysis_history.dart';

class CalendarCardWidget extends StatelessWidget {
  CalendarCardWidget({super.key, required this.analysisHistory});

  final List<AnalysisHistory> analysisHistory;

  final ValueNotifier<List<AnalysisHistory>> _selectedEvent = ValueNotifier([]);

  void _onChangeDate(DateTime selectedDay, List<AnalysisHistory> Function(DateTime) getEventForDay) {
    _selectedEvent.value = getEventForDay(selectedDay);
  }

  Widget _buildButton({
    required String imagePath,
    required Color color,
    required Function() onPressed,
    required BuildContext context,
    required double buttonWidth,
    bool? isInDevelopment,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) * buttonWidth - 20,
      height: 75,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(1, 1),
            blurRadius: 1,
            color: color.withOpacity(1),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(0),
        ),
        onPressed: onPressed,
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: (buttonWidth == 1) ? 175 : 125,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(12.0),
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
          CalendarWidget(
            analysisHistory: analysisHistory,
            onChangeDate: _onChangeDate,
            calendarFormat: CalendarFormat.month,
          ),
          ValueListenableBuilder<List>(
            valueListenable: _selectedEvent,
            builder: (ctx, value, _) {
              return (value.isEmpty)
                  ? const SizedBox()
                  : Column(
                      children: [
                        _buildButton(
                          imagePath: "assets/images/home_illustrations/jerawat.png",
                          color: const Color(0xFF89E2E8),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => JerawatHistoryScreen(
                                      selectedAnalysisHistory: _selectedEvent.value,
                                      analysisHistory: analysisHistory,
                                    )));
                          },
                          buttonWidth: 1,
                          context: context,
                        ),
                        Row(
                          children: [
                            _buildButton(
                              imagePath: "assets/images/home_illustrations/keriput.png",
                              color: const Color(0xFFFFBBBB),
                              onPressed: () {},
                              buttonWidth: 0.5,
                              context: context,
                              isInDevelopment: true,
                            ),
                            _buildButton(
                              imagePath: "assets/images/home_illustrations/kemerahan.png",
                              color: const Color(0xFFF880AB),
                              onPressed: () {},
                              buttonWidth: 0.5,
                              context: context,
                              isInDevelopment: true,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildButton(
                              imagePath: "assets/images/home_illustrations/bercak-hitam.png",
                              color: const Color(0xFF8FE1AE),
                              onPressed: () {},
                              buttonWidth: 0.5,
                              context: context,
                              isInDevelopment: true,
                            ),
                            _buildButton(
                              imagePath: "assets/images/home_illustrations/jenis-kulit.png",
                              color: const Color(0xFFA3A2F5),
                              onPressed: () {},
                              buttonWidth: 0.5,
                              context: context,
                              isInDevelopment: true,
                            ),
                          ],
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}
