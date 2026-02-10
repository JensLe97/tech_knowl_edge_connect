import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:tech_knowl_edge_connect/components/answer_field.dart';
import 'package:tech_knowl_edge_connect/components/learning/cloze_markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';

class SingleChoiceClozeTask extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;
  final Function(bool) onResult;

  const SingleChoiceClozeTask({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onResult,
  });

  @override
  State<SingleChoiceClozeTask> createState() => _SingleChoiceClozeTaskState();
}

class _SingleChoiceClozeTaskState extends State<SingleChoiceClozeTask> {
  late TextEditingController controller;
  List<String> correctAnswersParts = [];

  int? answeredIndex;
  bool isAnswered = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _parseTask();
  }

  void _parseTask() {
    correctAnswersParts = widget.task.correctAnswer.split('{}');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MarkdownBody(
            data: widget.task.question,
            extensionSet: md.ExtensionSet(
              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
              [
                ClozeSyntax(),
                ColorSyntax(),
                ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
              ],
            ),
            builders: {
              ...getMarkdownColorBuilders(),
              'cloze': ClozeBuilder(correctAnswersParts, (index, answer) {
                return AnswerField(
                  setAllCorrect: () {}, // Not used since disabled
                  controller: controller,
                  answer: answer,
                  enabled: false,
                );
              }),
            },
            styleSheet: createMarkdownStyleSheet(context),
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
                      if (correct) {
                        controller.text = widget.task.correctAnswer;
                      }
                    });

                    await Future.delayed(const Duration(seconds: 1));

                    if (correct) {
                      widget.onComplete();
                    } else {
                      if (mounted) {
                        setState(() {
                          isAnswered = false;
                          answeredIndex = null;
                          controller.text = "";
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
