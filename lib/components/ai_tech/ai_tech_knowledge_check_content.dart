import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/ai_tech/ai_tech_knowledge_check_activity_indicator.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_knowledge_check_answer.dart';

class AiTechKnowledgeCheckContent extends StatelessWidget {
  final bool isComplete;
  final List<AiTechKnowledgeCheckAnswer> resultAnswers;
  final String nextAction;
  final String question;
  final String? statusMessage;
  final bool isErrorStatus;
  final bool isSpeaking;
  final bool isAnalyzing;
  final bool isRecording;
  final bool hasCurrentAnswer;
  final List<String> responses;
  final List<String> answerFeedback;
  final VoidCallback onStopSpeaking;
  final VoidCallback onSpeakQuestion;

  const AiTechKnowledgeCheckContent({
    super.key,
    required this.isComplete,
    required this.resultAnswers,
    required this.nextAction,
    required this.question,
    required this.statusMessage,
    required this.isErrorStatus,
    required this.isSpeaking,
    required this.isAnalyzing,
    required this.isRecording,
    required this.hasCurrentAnswer,
    required this.responses,
    required this.answerFeedback,
    required this.onStopSpeaking,
    required this.onSpeakQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return isComplete
        ? _AiTechKnowledgeCheckCompletion(
            resultAnswers: resultAnswers,
            nextAction: nextAction,
          )
        : _AiTechKnowledgeCheckQuestion(
            question: question,
            statusMessage: statusMessage,
            isErrorStatus: isErrorStatus,
            isSpeaking: isSpeaking,
            isAnalyzing: isAnalyzing,
            isRecording: isRecording,
            hasCurrentAnswer: hasCurrentAnswer,
            response: responses.isEmpty ? null : responses.last,
            feedback: answerFeedback.isEmpty ? null : answerFeedback.last,
            onStopSpeaking: onStopSpeaking,
            onSpeakQuestion: onSpeakQuestion,
          );
  }
}

class _AiTechKnowledgeCheckCompletion extends StatelessWidget {
  final List<AiTechKnowledgeCheckAnswer> resultAnswers;
  final String nextAction;

  const _AiTechKnowledgeCheckCompletion({
    required this.resultAnswers,
    required this.nextAction,
  });

  @override
  Widget build(BuildContext context) {
    final correctAnswers = resultAnswers
        .where((answer) => answer.isCorrect)
        .length;
    final ratio = resultAnswers.isNotEmpty
        ? correctAnswers / resultAnswers.length
        : 0.0;
    final completedEmojis = ['✅', '🏁', '✔️', '🟢', '🎓'];
    final excellentEmojis = ['🎉', '🏆', '🥇', '🎖️', '🌟'];
    final greatEmojis = ['👍', '🙌', '✨', '💯', '🥈'];
    final practiceEmojis = ['💪', '🔁', '📈', '🛠️', '🤓'];
    final String headerText;
    final IconData headerIcon;
    final Color iconColor;
    final List<String> emojis;

    if (resultAnswers.isEmpty) {
      headerText = 'Absolviert!';
      headerIcon = Icons.task_alt;
      iconColor = Colors.green;
      emojis = completedEmojis;
    } else if (ratio >= 0.9) {
      headerText = 'Super gemacht!';
      headerIcon = Icons.rocket_launch;
      iconColor = Colors.amber.shade700;
      emojis = excellentEmojis;
    } else if (ratio >= 0.5) {
      headerText = 'Gut gemacht!';
      headerIcon = Icons.thumb_up;
      iconColor = Theme.of(context).colorScheme.primary;
      emojis = greatEmojis;
    } else {
      headerText = 'Übe weiter!';
      headerIcon = Icons.fitness_center;
      iconColor = Colors.orange;
      emojis = practiceEmojis;
    }

    final emoji = emojis[Random().nextInt(emojis.length)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('AI TECH WISSENSCHECK'),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withAlpha(50),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withAlpha(40),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Icon(headerIcon, size: 52, color: iconColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$emoji  $headerText',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${resultAnswers.length} '
          '${resultAnswers.length == 1 ? 'Frage' : 'Fragen'} · '
          '$correctAnswers korrekt',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _NextStepCard(nextAction: nextAction),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SectionLabel('DEINE ANTWORTEN (${resultAnswers.length})'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...resultAnswers.indexed.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _ResultAnswerCard(index: entry.$1 + 1, answer: entry.$2),
          ),
        ),
        const SizedBox(height: 16),
        const _FeedbackDisclaimer(),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final String nextAction;

  const _NextStepCard({required this.nextAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withAlpha(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEIN NÄCHSTER SCHRITT',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          _ResultMarkdown(data: nextAction),
        ],
      ),
    );
  }
}

class _ResultAnswerCard extends StatelessWidget {
  final int index;
  final AiTechKnowledgeCheckAnswer answer;

  const _ResultAnswerCard({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(60)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: colorScheme.surfaceContainerLowest,
          collapsedBackgroundColor: colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          visualDensity: VisualDensity.compact,
          leading: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: answer.isCorrect
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: answer.isCorrect
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            answer.question,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            answer.isCorrect ? 'Korrekt' : 'Details ansehen',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: answer.isCorrect
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ResultSectionLabel('DEINE ANTWORT'),
                  const SizedBox(height: 4),
                  _ResultMarkdown(data: answer.answer),
                  const SizedBox(height: 10),
                  const _ResultSectionLabel('RÜCKMELDUNG'),
                  const SizedBox(height: 4),
                  _ResultMarkdown(data: answer.feedback),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSectionLabel extends StatelessWidget {
  final String text;

  const _ResultSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ResultMarkdown extends StatelessWidget {
  final String data;

  const _ResultMarkdown({required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      extensionSet: getMarkdownExtensionSet(),
      builders: getMarkdownColorBuilders(),
      styleSheet: createMarkdownStyleSheet(context).copyWith(
        p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }
}

class _AiTechKnowledgeCheckQuestion extends StatelessWidget {
  final String question;
  final String? statusMessage;
  final bool isErrorStatus;
  final bool isSpeaking;
  final bool isAnalyzing;
  final bool isRecording;
  final bool hasCurrentAnswer;
  final String? response;
  final String? feedback;
  final VoidCallback onStopSpeaking;
  final VoidCallback onSpeakQuestion;

  const _AiTechKnowledgeCheckQuestion({
    required this.question,
    required this.statusMessage,
    required this.isErrorStatus,
    required this.isSpeaking,
    required this.isAnalyzing,
    required this.isRecording,
    required this.hasCurrentAnswer,
    required this.response,
    required this.feedback,
    required this.onStopSpeaking,
    required this.onSpeakQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('AI TECH WISSENSCHECK'),
        const SizedBox(height: 8),
        Text(
          'Höre zu und antworte in deinen eigenen Worten.',
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
              color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: question,
                extensionSet: getMarkdownExtensionSet(),
                builders: getMarkdownColorBuilders(),
                styleSheet: createMarkdownStyleSheet(context).copyWith(
                  p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isSpeaking || isAnalyzing)
                    AiTechKnowledgeCheckActivityIndicator(
                      analyzing: isAnalyzing,
                    ),
                  if (isSpeaking || isAnalyzing) const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: isRecording || isAnalyzing
                        ? null
                        : isSpeaking
                        ? onStopSpeaking
                        : onSpeakQuestion,
                    icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
                    tooltip: isSpeaking ? 'Vorlesen stoppen' : 'Frage vorlesen',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (statusMessage != null && !isAnalyzing) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isErrorStatus
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isErrorStatus
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
        if (hasCurrentAnswer && response != null) ...[
          const SizedBox(height: 24),
          _SectionLabel('DEINE ANTWORT'),
          const SizedBox(height: 8),
          _MarkdownCard(
            data: response!,
            padding: const EdgeInsets.all(20),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ],
        if (hasCurrentAnswer && feedback != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel('RÜCKMELDUNG'),
                const SizedBox(height: 8),
                MarkdownBody(
                  data: feedback!,
                  extensionSet: getMarkdownExtensionSet(),
                  builders: getMarkdownColorBuilders(),
                  styleSheet: createMarkdownStyleSheet(context).copyWith(
                    p: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Die Audioaufnahme wird zur Auswertung an Firebase AI gesendet und '
          'nicht als Audiodatei in der App gespeichert.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        const _FeedbackDisclaimer(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MarkdownCard extends StatelessWidget {
  final String data;
  final EdgeInsets padding;
  final Color backgroundColor;

  const _MarkdownCard({
    required this.data,
    required this.padding,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: MarkdownBody(
        data: data,
        extensionSet: getMarkdownExtensionSet(),
        builders: getMarkdownColorBuilders(),
        styleSheet: createMarkdownStyleSheet(context).copyWith(
          p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ),
    );
  }
}

class _FeedbackDisclaimer extends StatelessWidget {
  const _FeedbackDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'AI-generierte Rückmeldung ist beratend und ersetzt keine Einschätzung '
      'durch Menschen.',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
