import 'package:flutter/foundation.dart';
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
          const SizedBox(height: 83),
          const Text("Starte jetzt durch mit", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 5),
          const Text("TechKnowlEdgeConnect", style: TextStyle(fontSize: 22)),
          kIsWeb
              ? SizedBox(
                  height: 500,
                  child: Image.asset(
                      'images/learning_bites/math/numbers_naming/numbers.png'),
                )
              : Lottie.asset(
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
