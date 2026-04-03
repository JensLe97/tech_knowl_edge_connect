import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';

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
                MarkdownBody(
                  data: widget.task.question,
                  extensionSet: getMarkdownExtensionSet(),
                  builders: getMarkdownColorBuilders(),
                  styleSheet: createMarkdownStyleSheet(context).copyWith(
                    p: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
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
