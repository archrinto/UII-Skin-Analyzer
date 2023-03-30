import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_screen.dart';
import '../onboarding/onboarding_screen.dart';

//* https://blog.logrocket.com/make-splash-screen-flutter/
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var animated = false;

  void whenAnimationDone() async {
    final navigator = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();
    final isCachedImageExists = prefs.getString('cachedImage');

    if (isCachedImageExists == null) {
      navigator.pushReplacementNamed(OnboardingScreen.routeName);
    } else {
      navigator.pushReplacementNamed(MainScreen.routeName);
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() => animated = true))
        .then((value) => Future.delayed(const Duration(seconds: 2)).then((value) => whenAnimationDone()));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FF),
      body: SizedBox(
        width: double.infinity,
        child: AnimatedOpacity(
          opacity: !animated ? 0 : 1,
          duration: const Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: Image.asset(
                  "assets/icons/logo.png",
                ),
              ),
              const Text(
                "Skin Analyzer",
                style: TextStyle(
                  color: Color(0xFF1287C9),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "by Universitas Islam Indonesia",
                style: TextStyle(
                  color: Color(0xFF1287C9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
