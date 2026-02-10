import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';

class SingleChoiceTask extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;
  final Function(bool) onResult;

  const SingleChoiceTask({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onResult,
  });

  @override
  State<SingleChoiceTask> createState() => _SingleChoiceTaskState();
}

class _SingleChoiceTaskState extends State<SingleChoiceTask> {
  int? answeredIndex;
  bool isAnswered = false;
  bool isCorrect = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MarkdownBody(
            data: widget.task.question,
            extensionSet: getMarkdownExtensionSet(),
            builders: getMarkdownColorBuilders(),
            styleSheet: createMarkdownStyleSheet(context).copyWith(
              textAlign: WrapAlignment.center,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            children: [
              for (var index = 0; index < widget.task.answers.length; index++)
                LessonButton(
                  onTap: () async {
                    if (isAnswered) return;

                    bool correct =
                        widget.task.answers[index] == widget.task.correctAnswer;

                    widget.onResult(correct);

                    setState(() {
                      answeredIndex = index;
                      isAnswered = true;
                      isCorrect = correct;
                    });

                    await Future.delayed(const Duration(seconds: 1));

                    if (correct) {
                      widget.onComplete();
                    } else {
                      if (mounted) {
                        setState(() {
                          isAnswered = false;
                          answeredIndex = null;
                        });
                      }
                    }
                  },
                  text: widget.task.answers[index],
                  color: isAnswered && answeredIndex == index
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Theme.of(context).colorScheme.secondary,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
