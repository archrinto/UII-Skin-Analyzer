import 'package:flutter/material.dart';
import 'package:uii_skin_analyzer/widgets/utility/dialog_widget.dart';

import './analysis/jerawat_analysis_screen.dart';
import './analysis/keriput_analysis_screen.dart';
import './analysis/kemerahan_analysis_screen.dart';
import './analysis/bercak_hitam_analysis_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildMenuButton({
    required String buttonTitle,
    required String imagePath,
    required double buttonWidth,
    required Color color,
    required BuildContext context,
    required Function() onPressed,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * buttonWidth - 20,
      height: MediaQuery.of(context).size.height * 0.25,
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
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                width: (buttonWidth == 1) ? 175 : 125,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18, left: 12),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buttonTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (buttonWidth == 1) ? 30 : 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Text(
              "Ayo pilih apa yang\ningin kamu analisis!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildMenuButton(
            buttonTitle: "Jerawat",
            imagePath: "assets/images/home_illustrations/jerawat.png",
            color: const Color(0xFF89E2E8),
            onPressed: () {
              Navigator.of(context).pushNamed(JerawatAnalysisScreen.routeName);
            },
            buttonWidth: 1,
            context: context,
          ),
          Row(
            children: [
              _buildMenuButton(
                buttonTitle: "Keriput",
                imagePath: "assets/images/home_illustrations/keriput.png",
                color: const Color(0xFFFFBBBB),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(KeriputAnalysisScreen.routeName);
                },
                buttonWidth: 0.5,
                context: context,
              ),
              _buildMenuButton(
                buttonTitle: "Kemerahan",
                imagePath: "assets/images/home_illustrations/kemerahan.png",
                color: const Color(0xFFF880AB),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(KemerahanAnalysisScreen.routeName);
                },
                buttonWidth: 0.5,
                context: context,
              ),
            ],
          ),
          Row(
            children: [
              _buildMenuButton(
                buttonTitle: "Bercak Hitam",
                imagePath: "assets/images/home_illustrations/bercak-hitam.png",
                color: const Color(0xFF8FE1AE),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(BercakHitamAnalysisScreen.routeName);
                },
                buttonWidth: 0.5,
                context: context,
              ),
              _buildMenuButton(
                buttonTitle: "Jenis Kulit",
                imagePath: "assets/images/home_illustrations/jenis-kulit.png",
                color: const Color(0xFFA3A2F5),
                onPressed: () {
                  buildDialog(
                    context: context,
                    title: 'Pesan',
                    content: const Text(
                      'Fitur masih dalam pengembangan',
                      textAlign: TextAlign.justify,
                    ),
                    actionButton: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: buildActionButton(context, 'OK'),
                      ),
                    ],
                  );
                },
                buttonWidth: 0.5,
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
