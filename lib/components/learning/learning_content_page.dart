import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/buttons/bottom_action_bar.dart';

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
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 10, bottom: 120),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withAlpha(50),
                ),
              ),
              child: MarkdownBody(
                data: text,
                extensionSet: getMarkdownExtensionSet(),
                builders: getMarkdownColorBuilders(),
                styleSheet: createMarkdownStyleSheet(context),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomActionBar(
            text: "Weiter",
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}
