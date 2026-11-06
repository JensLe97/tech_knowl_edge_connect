import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tech_knowl_edge_connect/components/ai_tech/ai_tech_knowledge_check_activity_indicator.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';

class AiTechKnowledgeCheckContent extends StatelessWidget {
  final bool isComplete;
  final String summary;
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
    required this.summary,
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
        ? _AiTechKnowledgeCheckCompletion(summary: summary)
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
  final String summary;

  const _AiTechKnowledgeCheckCompletion({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('AI TECH WISSENSCHECK'),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withAlpha(50),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AI Tech Wissenscheck abgeschlossen',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        _MarkdownCard(
          data: summary,
          padding: const EdgeInsets.all(24),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        const SizedBox(height: 16),
        const _FeedbackDisclaimer(),
      ],
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
                    tooltip: isSpeaking
                        ? 'Vorlesen stoppen'
                        : 'Frage erneut vorlesen',
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
