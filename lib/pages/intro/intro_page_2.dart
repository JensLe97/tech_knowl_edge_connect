import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 83),
          const Text("Erhalte jederzeit Zugriff auf Fachwissen",
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 5),
          const Text("aus Schule, Universität und Alltag",
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 15),
          Lottie.asset(
            'images/animations/knowledge_animation.json',
            height: 400,
          ),
          const SizedBox(height: 30),
          const Text("Einfach und anschaulich lernen",
              style: TextStyle(fontSize: 18))
        ],
      ),
    );
  }
}
