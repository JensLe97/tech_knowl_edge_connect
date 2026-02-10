import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';

class LearningContentPage extends StatelessWidget {
  final String text;
  final VoidCallback onNext;

  const LearningContentPage({
    super.key,
    required this.text,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MarkdownBody(
              data: text,
              extensionSet: getMarkdownExtensionSet(),
              builders: getMarkdownColorBuilders(),
              styleSheet: createMarkdownStyleSheet(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Wrap(direction: Axis.horizontal, children: [
            LessonButton(
              onTap: onNext,
              text: "Weiter",
            )
          ]),
        ),
      ],
    );
  }
}
