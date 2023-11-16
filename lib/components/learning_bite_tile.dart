import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:tech_knowl_edge_connect/models/learning_bite.dart";

class LearingBiteTile extends StatelessWidget {
  final LearningBite learningBite;
  final void Function()? onTap;

  const LearingBiteTile({
    super.key,
    required this.learningBite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        width: 200,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FaIcon(learningBite.iconData, size: 30),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                learningBite.name,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
