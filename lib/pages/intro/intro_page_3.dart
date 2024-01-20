import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatefulWidget {
  const IntroPage3({super.key});

  @override
  State<IntroPage3> createState() => _IntroPage3State();
}

class _IntroPage3State extends State<IntroPage3> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 123),
          const Text("Starte jetzt durch mit", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 5),
          const Text("TechKnowlEdgeConnect", style: TextStyle(fontSize: 22)),
          Lottie.asset(
            'images/animations/rocket_animation.json',
            height: 400,
          ),
          const SizedBox(height: 38),
          const Text("Viel Spaß und Erfolg", style: TextStyle(fontSize: 18))
        ],
      ),
    );
  }
}
