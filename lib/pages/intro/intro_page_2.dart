import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tech_knowl_edge_connect/pages/intro/onboarding_slide.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      image: kIsWeb
          ? SizedBox(
              height: 400,
              child: Image.asset('images/knowledge.png'),
            )
          : Lottie.asset('images/animations/knowledge_animation.json',
              fit: BoxFit.fitWidth),
      badgeIcon: Icons.menu_book,
      badgeText: 'Dein Lern-Hub',
      titlePart1: 'Jederzeit Zugriff auf',
      titleHighlight: 'Fachwissen',
      subtitle:
          'Aus Schule, Universität und Alltag\nEinfach und anschaulich lernen',
    );
  }
}
