import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';

class LearningSummaryPage extends StatelessWidget {
  final int points;
  final int maxPoints;
  final VoidCallback onComplete;

  const LearningSummaryPage({
    super.key,
    required this.points,
    required this.maxPoints,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
              child: Column(
            children: [
              const SizedBox(height: 200),
              maxPoints > 0
                  ? (points / maxPoints >= 0.5
                      ? (points / maxPoints >= 0.9
                          ? MarkdownBody(
                              data: "Super gemacht!",
                              styleSheet: createMarkdownStyleSheet(context)
                                  .copyWith(
                                      p: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 22)),
                              extensionSet: getMarkdownExtensionSet(),
                              builders: getMarkdownColorBuilders(),
                            )
                          : MarkdownBody(
                              data: "Gut gemacht!",
                              styleSheet: createMarkdownStyleSheet(context)
                                  .copyWith(
                                      p: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 22)),
                              extensionSet: getMarkdownExtensionSet(),
                              builders: getMarkdownColorBuilders(),
                            ))
                      : MarkdownBody(
                          data: "Übe weiter!",
                          styleSheet: createMarkdownStyleSheet(context)
                              .copyWith(
                                  p: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontSize: 22)),
                          extensionSet: getMarkdownExtensionSet(),
                          builders: getMarkdownColorBuilders(),
                        ))
                  : MarkdownBody(
                      data: "Absolviert!",
                      styleSheet: createMarkdownStyleSheet(context).copyWith(
                          p: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 22)),
                      extensionSet: getMarkdownExtensionSet(),
                      builders: getMarkdownColorBuilders(),
                    ),
              const SizedBox(height: 50),
              MarkdownBody(
                  data: "Du hast $points von $maxPoints Punkten erhalten.",
                  styleSheet: createMarkdownStyleSheet(context),
                  extensionSet: getMarkdownExtensionSet(),
                  builders: getMarkdownColorBuilders()),
            ],
          )),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Wrap(direction: Axis.horizontal, children: [
            LessonButton(
              onTap: onComplete,
              text: "Lektion abschließen",
            )
          ]),
        ),
      ],
    );
  }
}
