import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:tech_knowl_edge_connect/components/forms/answer_field.dart';
import 'package:tech_knowl_edge_connect/components/learning/cloze_markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/buttons/bottom_action_bar.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';

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
                  "LÜCKENTEXT",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Fülle die Lücken aus.",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withAlpha(50),
                    ),
                  ),
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
                      'cloze':
                          ClozeBuilder(correctAnswersParts, (index, answer) {
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
                    styleSheet: createMarkdownStyleSheet(context).copyWith(
                      p: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (!allCorrect && !solutionShown)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withAlpha(80),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Tipp: Überprüfe deine Eingaben auf korrekte Rechtschreibung.",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomActionBar(
            child: (!allCorrect && !solutionShown)
                ? FilledButton.tonal(
                    onPressed: _showSolution,
                    child: const Text(
                      "Lösung anzeigen",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: () {
                      widget.onResult(!solutionShown);
                      widget.onComplete();
                    },
                    child: const Text(
                      "Weiter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
