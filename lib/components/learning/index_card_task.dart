import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

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
      question: "Gewusst?",
      correctAnswer: "Ja",
      answers: ["Nein", "Ja"]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              MarkdownBody(
                data: showAnswer
                    ? widget.task.correctAnswer
                    : widget.task.question,
                extensionSet: getMarkdownExtensionSet(),
                builders: getMarkdownColorBuilders(),
                styleSheet: createMarkdownStyleSheet(context).copyWith(
                  textAlign: WrapAlignment.center,
                ),
              ),
              if (showAnswer) ...[
                const SizedBox(height: 100),
                MarkdownBody(
                  data: _controlTask.question,
                  styleSheet: createMarkdownStyleSheet(context),
                  extensionSet: getMarkdownExtensionSet(),
                  builders: getMarkdownColorBuilders(),
                ),
              ]
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: showAnswer
              ? Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  children: [
                      for (var answerIndex = 0;
                          answerIndex < _controlTask.answers.length;
                          answerIndex++)
                        LessonButton(
                            onTap: () {
                              bool correct =
                                  _controlTask.answers[answerIndex] ==
                                      _controlTask.correctAnswer;

                              widget.onResult(correct);
                              widget.onComplete();
                            },
                            text: _controlTask.answers[answerIndex],
                            color: _controlTask.answers[answerIndex] ==
                                    _controlTask.correctAnswer
                                ? Colors.green
                                : Colors.red),
                    ])
              : Wrap(direction: Axis.horizontal, children: [
                  LessonButton(
                    onTap: () {
                      setState(() {
                        showAnswer = true;
                      });
                    },
                    text: "Prüfen",
                  )
                ]),
        ),
      ],
    );
  }
}
