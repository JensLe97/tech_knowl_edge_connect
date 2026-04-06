import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tech_knowl_edge_connect/pages/intro/onboarding_slide.dart';

class IntroPage3 extends StatefulWidget {
  const IntroPage3({super.key});

  @override
  State<IntroPage3> createState() => _IntroPage3State();
}

class _IntroPage3State extends State<IntroPage3> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      image: kIsWeb
          ? Image.asset('images/rocket.png', fit: BoxFit.fitWidth)
          : Lottie.asset('images/animations/rocket_animation.json',
              fit: BoxFit.fitWidth),
      badgeIcon: Icons.rocket_launch,
      badgeText: 'Beginne deine Reise',
      titlePart1: 'Starte jetzt durch mit',
      titleHighlight: 'TechKnowlEdge\u200B',
      titlePart2: 'Connect',
      subtitle: 'Wir wünschen dir viel Spaß und Erfolg!',
    );
  }
}
