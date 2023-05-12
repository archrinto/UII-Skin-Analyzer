import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utility/notification_card_widget.dart';
import '../../models/deteksi_model.dart';
import '../../helpers/draw_in_canvas.dart';

class AnalysisResultWidget extends StatelessWidget {
  const AnalysisResultWidget({
    super.key,
    required this.strokeWidth,
    this.isServerError = false,
    required this.notificationMessage,
    required this.imageFile,
    required this.objectData,
    this.saveResultButton = const SizedBox(),
    required this.canvasColor,
  });

  final double strokeWidth;
  final bool isServerError;
  final String notificationMessage;
  final File? imageFile;
  final List<DeteksiModel>? objectData;
  final Widget saveResultButton;
  final Color canvasColor;

  Widget _buildNotificationCard() {
    if (isServerError) {
      return const NotificationCard(
          cardColor: Color(0xFFC61717), cardIcon: Icons.cancel_outlined, cardText: 'Maaf, Server sedang tidak tersedia');
    }

    if (objectData == null) return const SizedBox();

    return NotificationCard(cardColor: const Color(0xFF17C672), cardIcon: Icons.check_circle_outline, cardText: notificationMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: (imageFile == null)
          ? Column(
              children: [
                Lottie.asset('assets/lotties/loader.json'),
                const Text(
                  'Unggah foto wajahmu untuk melakukan analisis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            )
          : Column(
              children: [
                _buildNotificationCard(),
                CustomPaint(
                  foregroundPainter: objectData == null
                      ? null
                      : DrawInCanvas(
                          color: canvasColor,
                          strokeWidth: strokeWidth,
                          objects: objectData!,
                        ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFCACACA),
                          ),
                        ),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      saveResultButton,
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
