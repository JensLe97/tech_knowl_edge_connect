import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:tech_knowl_edge_connect/components/answer_field.dart';
import 'package:tech_knowl_edge_connect/components/learning/cloze_markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/lesson_button.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';

class FreeTextFieldClozeTask extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;
  final Function(bool) onResult;

  const FreeTextFieldClozeTask({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onResult,
  });

  @override
  State<FreeTextFieldClozeTask> createState() => _FreeTextFieldClozeTaskState();
}

class _FreeTextFieldClozeTaskState extends State<FreeTextFieldClozeTask> {
  List<TextEditingController> controllers = [];
  List<String> correctAnswersParts = [];
  bool allCorrect = false;
  bool solutionShown = false;

  void _showSolution() {
    setState(() {
      solutionShown = true;
      for (var i = 0; i < controllers.length; i++) {
        controllers[i].text = correctAnswersParts[i];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _parseTask();
  }

  void _parseTask() {
    correctAnswersParts = widget.task.correctAnswer.split('{}');
    // Using simple split for answers, question is parsed by Markdown

    controllers = List.generate(
        correctAnswersParts.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkAllCorrect() {
    for (var i = 0; i < correctAnswersParts.length; i++) {
      if (correctAnswersParts[i].toLowerCase() !=
          controllers[i].text.toLowerCase()) {
        setState(() {
          allCorrect = false;
        });
        return;
      }
    }
    setState(() {
      allCorrect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MarkdownBody(
            key: ValueKey(solutionShown),
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
                if (index < controllers.length) {
                  return AnswerField(
                    setAllCorrect: _checkAllCorrect,
                    controller: controllers[index],
                    answer: answer,
                    enabled: !solutionShown,
                    textInputAction: index < controllers.length - 1
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofocus: index == 0,
                  );
                }
                return const SizedBox.shrink();
              }),
            },
            styleSheet: createMarkdownStyleSheet(context),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Wrap(direction: Axis.horizontal, children: [
            if (!allCorrect && !solutionShown)
              LessonButton(
                onTap: _showSolution,
                text: "Lösung anzeigen",
              ),
            if (allCorrect || solutionShown)
              LessonButton(
                onTap: () {
                  widget.onResult(!solutionShown);
                  widget.onComplete();
                },
                text: "Weiter",
              )
          ]),
        ),
      ],
    );
  }
}
