import 'package:flutter/material.dart';

class IdeaReactionButton extends StatelessWidget {
  final IconData icon;
  final int number;
  final bool hasCounter;

  const IdeaReactionButton(
      {super.key, required this.icon, this.number = 0, this.hasCounter = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          hasCounter
              ? Text(number.toString(),
                  style: const TextStyle(color: Colors.white))
              : const SizedBox(),
        ],
      ),
    );
  }
}
