import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:tech_knowl_edge_connect/components/learning/cloze_markdown_support.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';

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
                  "WISSENSCHECK",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Wähle die korrekte Antwort.",
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
                    key: ValueKey('$isAnswered-$isCorrect'),
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
                        Color textColor = isAnswered && isCorrect
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary;

                        double calculatedWidth = (TextPainter(
                                        text: TextSpan(
                                            text: answer,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            )),
                                        textScaler:
                                            MediaQuery.of(context).textScaler,
                                        textDirection: TextDirection.ltr)
                                      ..layout())
                                    .size
                                    .width *
                                1.02 +
                            28; // Extra padding for web font rendering and TextField margins

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            width: calculatedWidth < 45 ? 45 : calculatedWidth,
                            child: TextField(
                              controller: controller,
                              enabled: false,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.only(
                                    left: 4, right: 4, top: 6, bottom: 6),
                                disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: textColor == Colors.green
                                        ? Colors.green
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withAlpha(100),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
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
                for (var index = 0; index < widget.task.answers.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildAnswerCard(index),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerCard(int index) {
    String answerText = widget.task.answers[index];
    bool isSelected = isAnswered && answeredIndex == index;

    Color backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
    Color borderColor =
        Theme.of(context).colorScheme.outlineVariant.withAlpha(50);
    Widget icon = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 2,
        ),
      ),
    );

    if (isSelected) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100.withAlpha(50);
        borderColor = Colors.green;
        icon = Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        );
      } else {
        backgroundColor =
            Theme.of(context).colorScheme.errorContainer.withAlpha(50);
        borderColor = Theme.of(context).colorScheme.error;
        icon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.error,
          ),
          child: Icon(Icons.close,
              size: 16, color: Theme.of(context).colorScheme.onError),
        );
      }
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (isAnswered) return;

          bool correct = answerText == widget.task.correctAnswer;
          widget.onResult(correct);

          setState(() {
            answeredIndex = index;
            isAnswered = true;
            isCorrect = correct;
            if (correct) {
              controller.text = answerText;
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answerText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}
