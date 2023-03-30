import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../helpers/functions.dart';
import '../../models/analysis_history.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({super.key, required this.analysisHistory});

  final List<AnalysisHistory> analysisHistory;

  final List<Color> gradientColors = const [
    Color(0xff23b6e6),
    Color(0xff02d39a),
  ];

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('1', style: style);
        break;
      case 5:
        text = const Text('5', style: style);
        break;
      case 10:
        text = const Text('10', style: style);
        break;
      case 15:
        text = const Text('15', style: style);
        break;
      case 20:
        text = const Text('20', style: style);
        break;
      case 25:
        text = const Text('25', style: style);
        break;
      case 30:
        text = const Text('30', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1';
        break;
      case 10:
        text = '10';
        break;
      case 20:
        text = '20';
        break;
      case 30:
        text = '30';
        break;
      default:
        return Container();
    }

    return Column(
      children: [
        Text(text, style: style, textAlign: TextAlign.left),
        const Text(
          ' Jerawat',
          style: TextStyle(
            fontSize: 10,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 50,
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '${barSpot.y.round().toString()} \n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Jerawat \n',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${barSpot.x.round().toString()} ${DateFormat.MMMM('id_ID').format(DateTime.parse(analysisHistory[0].date))}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  textAlign: TextAlign.center,
                );
              }).toList();
            },
          ),
        ),
        minX: 0,
        maxX: 31,
        minY: -1,
        maxY: 31,
        lineBarsData: [
          LineChartBarData(
            dotData: FlDotData(),
            spots: analysisHistory
                .map(
                  (item) => FlSpot(
                    DateTime.parse(item.date).day.toDouble(),
                    generateJerawats(item.jerawatResult!).length.toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 5,
            isStrokeCapRound: true,
          ),
        ],
      ),
    );
  }
}
