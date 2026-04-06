import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tech_knowl_edge_connect/pages/intro/onboarding_slide.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key});

  @override
  State<IntroPage1> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      image: kIsWeb
          ? Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCHfFE1QCXEl8cTJJp2linIGwc3U_LaHtODJZP9asBUvgW1SHDDoIsGM-s_-7PmOgtabI8-7rpW7fjYTMV--RfXNo6-0AhdcyKb1Nj3EopG3rSkUexU6KejgwzJpkGnSHpBj5CZgubGYHJkBe0fOZ-TjQZazibG6MEXvbSy5HaCmHdT3fW6cbgk2eGIB7JIlblm6wbmekeLG0V8CNs0FKvIyYff6bql2tODOUjGCZgrZNdJQ5CJz88ax0j9cR9t5kAFogN_9xwMgmpo',
              fit: BoxFit.cover,
            )
          : Lottie.asset('images/animations/technology_animation.json',
              fit: BoxFit.fitWidth),
      badgeIcon: Icons.trending_up,
      badgeText: 'Dein Fortschritt',
      titlePart1: 'Willkommen bei',
      titleHighlight: 'TechKnowlEdge\u200B',
      titlePart2: 'Connect',
      subtitle: 'Wachse mit deinem Wissen',
    );
  }
}
