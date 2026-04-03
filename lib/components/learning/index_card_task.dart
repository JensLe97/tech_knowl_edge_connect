import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/buttons/bottom_action_bar.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';
import 'package:tech_knowl_edge_connect/models/learning/task_type.dart';

class IndexCardTask extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;
  final Function(bool) onResult;

  const IndexCardTask({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onResult,
  });

  @override
  State<IndexCardTask> createState() => _IndexCardTaskState();
}

class _IndexCardTaskState extends State<IndexCardTask> {
  bool showAnswer = false;

  final Task _controlTask = Task(
      id: "index_card_control",
      type: TaskType.indexCard,
      question: "## **Gewusst?**",
      correctAnswer: "Ja",
      answers: ["Nein", "Ja"]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 10, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KARTEIKARTE",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showAnswer ? "Lösung" : "Überlege die Antwort...",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
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
                    data: showAnswer
                        ? widget.task.correctAnswer
                        : widget.task.question,
                    extensionSet: getMarkdownExtensionSet(),
                    builders: getMarkdownColorBuilders(),
                    styleSheet: createMarkdownStyleSheet(context).copyWith(
                      textAlign: WrapAlignment.center,
                    ),
                  ),
                ),
                if (showAnswer) ...[
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      _controlTask.question
                          .replaceAll('## **', '')
                          .replaceAll('**', ''),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        if (!showAnswer)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(
              text: "Prüfen",
              onPressed: () {
                setState(() {
                  showAnswer = true;
                });
              },
            ),
          ),
        if (showAnswer)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(
              child: Row(
                children: [
                  for (var answerIndex = 0;
                      answerIndex < _controlTask.answers.length;
                      answerIndex++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: answerIndex == 0 ? 8.0 : 0,
                          left: answerIndex == 1 ? 8.0 : 0,
                        ),
                        child: FilledButton(
                          onPressed: () {
                            bool correct = _controlTask.answers[answerIndex] ==
                                _controlTask.correctAnswer;
                            widget.onResult(correct);
                            widget.onComplete();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                _controlTask.answers[answerIndex] ==
                                        _controlTask.correctAnswer
                                    ? Colors.green.withAlpha(200)
                                    : Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withAlpha(200),
                          ),
                          child: Text(
                            _controlTask.answers[answerIndex],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
