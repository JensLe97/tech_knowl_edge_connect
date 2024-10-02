import 'package:flutter/material.dart';

class IdeaReactionButton extends StatelessWidget {
  final Function()? onTap;
  final IconData icon;
  final int number;
  final bool hasCounter;
  final bool isLiked;

  const IdeaReactionButton(
      {super.key,
      required this.onTap,
      required this.icon,
      this.number = 0,
      this.hasCounter = true,
      this.isLiked = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isLiked ? Colors.red : Colors.white,
            ),
            const SizedBox(height: 10),
            hasCounter
                ? Text(number.toString(),
                    style: const TextStyle(color: Colors.white))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
