import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key});

  @override
  State<IntroPage1> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 120),
          const Text("Gude Friends", style: TextStyle(fontSize: 22)),
          const SizedBox(height: 15),
          const Text("Willkommen bei TechKnowlEdgeConnect",
              style: TextStyle(fontSize: 20)),
          const SizedBox(height: 15),
          Lottie.asset(
            'images/animations/technology_animation.json',
            height: 375,
          ),
          const SizedBox(height: 40),
          const Text("Wachse mit deinem Wissen", style: TextStyle(fontSize: 18))
        ],
      ),
    );
  }
}
