import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/data/concepts/index.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';

class ResumeTile extends StatelessWidget {
  final String path;
  final Subject subject;
  final LearningBite learningBite;
  final void Function()? onTap;

  const ResumeTile({
    super.key,
    required this.path,
    required this.subject,
    required this.learningBite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: subject.color, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Icon(
              subject.iconData,
              size: 55,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(path),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(learningBite.name),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
