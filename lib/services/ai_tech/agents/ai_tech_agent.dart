import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/agent_task.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_message.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/explain_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/hint_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/quiz_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/learning_journey_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/feedback_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/analyze_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/general_purpose_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/review_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';

/// The structured response returned by [AiTechOrchestrator.chat].
class OrchestratorResponse {
  /// Which agent skill handled the request.
  final AgentIntent intent;

  /// The chat-bubble text to display to the user.
  final String message;

  /// Set when [intent] is a journey intent – the Firestore document ID of the
  /// newly created (or updated) learning journey.
  final String? journeyId;

  const OrchestratorResponse({
    required this.intent,
    required this.message,
    this.journeyId,
  });
}

/// Abstract contract every top-level agent must fulfil.
abstract class AiTechAgent {
  Future<OrchestratorResponse> chat({
    required String userMessage,
    required String userId,
    required String sessionId,
    required String sessionTitle,
    List<Part> fileParts = const [],
    List<Map<String, dynamic>> fileAttachments = const [],
  });
}

/// The single public interface users interact with.
///
/// Lifecycle of one turn:
/// 1. Persist the user message to Firestore.
/// 2. Load the last [_contextWindowSize] messages as AI context.
/// 3. [AnalyzeAgent] determines which specialised agent to call.
/// 4. The chosen agent produces a response.
/// 5. The assistant message is persisted to Firestore.
/// 6. An [OrchestratorResponse] is returned for the UI to consume.
///
/// When the user finishes all bites in a journey, call [triggerFeedback].
/// The orchestrator runs the [FeedbackAgent], which updates the journey with
/// new bites (reinforcement or the next concept) and posts a chat notification.
class AiTechOrchestrator implements AiTechAgent {
  final AiTechService service;
  final ExplainAgent _explainAgent;
  final HintAgent _hintAgent;
  final QuizAgent _quizAgent;
  final LearningJourneyAgent _journeyAgent;
  final FeedbackAgent _feedbackAgent;
  final AnalyzeAgent _analyzeAgent;
  final GeneralPurposeAgent _generalAgent;
  final ReviewAgent _reviewAgent;

  /// Rolling context window – number of recent messages sent to agents.
  static const int _contextWindowSize = 12;

  AiTechOrchestrator(this.service)
      : _explainAgent = ExplainAgent(),
        _hintAgent = HintAgent(),
        _quizAgent = QuizAgent(),
        _journeyAgent = LearningJourneyAgent(service),
        _feedbackAgent = FeedbackAgent(service),
        _analyzeAgent = AnalyzeAgent(),
        _generalAgent = GeneralPurposeAgent(),
        _reviewAgent = ReviewAgent();

  // ---------------------------------------------------------------------------
  // Primary entry point
  // ---------------------------------------------------------------------------

  /// Handle one user turn.
  ///
  /// Persists both the user message and the assistant response to Firestore so
  /// the page's stream automatically shows them. Returns an
  /// [OrchestratorResponse] for any extra UI logic (e.g. journey card).
  @override
  Future<OrchestratorResponse> chat({
    required String userMessage,
    required String userId,
    required String sessionId,
    required String sessionTitle,
    List<Part> fileParts = const [],
    List<Map<String, dynamic>> fileAttachments = const [],
  }) async {
    // 1. Persist the user message first so history is up to date.
    await service.addMessage(
      sessionId,
      AiTechMessage(
        role: 'user',
        text: userMessage,
        ts: DateTime.now(),
        type: 'text',
        meta: (fileParts.isEmpty && fileAttachments.isEmpty)
            ? null
            : {
                if (fileParts.isNotEmpty) 'attachmentCount': fileParts.length,
                if (fileAttachments.isNotEmpty) 'attachments': fileAttachments,
              },
      ),
    );

// 2. Load session history and build structured content for chat agents.
    final history = await service.getSessionMessages(sessionId);
    // Exclude the just-persisted user message (last item) so it becomes the
    // explicit sendMessage() call inside each agent.
    final priorMessages = history.length > 1
        ? history.sublist(0, history.length - 1)
        : <AiTechMessage>[];
    final contentHistory = _buildContentHistory(priorMessages);
    // String context still used by structured one-shot agents (journey, analyze).
    final contextStr = _buildContextString(history, sessionTitle);

    // 3. Determine which agent + skill to invoke.
    final intent = await _analyzeAgent.analyze(
      userMessage,
      history: contentHistory,
      fileParts: fileParts,
    );

    String responseText;
    String? journeyId;

    switch (intent) {
      // -----------------------------------------------------------------------
      // LearningJourneyAgent skills
      // -----------------------------------------------------------------------

      case JourneyIntent(skill: JourneySkill.create):
        // Derive a short, specific title from this exact user request so
        // each journey has its own goal (e.g. "SQL Grundlagen") rather than
        // inheriting the broader session title (e.g. "Datenbanken").
        final journeyGoal = await generateSessionTitle(
          userMessage,
          fallback: sessionTitle.isNotEmpty ? sessionTitle : userMessage,
        );
        journeyId = await _journeyAgent.createLearningJourney(
          userId: userId,
          sessionId: sessionId,
          goal: journeyGoal,
          preferredSubjects: [journeyGoal],
          length: 2,
          userMessage: userMessage,
          context: contextStr,
          fileParts: fileParts,
        );
        responseText = 'Ich habe eine Lernreise zu "$journeyGoal" erstellt. '
            'Klicke auf eine Lerneinheit, um zu starten!';

      case JourneyIntent(skill: JourneySkill.update):
        // User confirmed a post-analysis recommendation OR explicitly requested
        // a journey adjustment. In both cases LearningJourneyAgent generates
        // new content; FeedbackAgent supplies the response message.
        final journeysSnapU = await service.streamJourneys(sessionId).first;
        if (journeysSnapU.docs.isNotEmpty) {
          final latestJourneyId = journeysSnapU.docs.last.id;
          final journeyData = await service.getJourneyById(latestJourneyId);
          final journeyGoalU = (journeyData?['goal'] as String?)?.trim() ?? '';
          final hasPending = journeyData?['pendingRecommendation'] != null;

          if (hasPending) {
            // User confirmed the stored recommendation from FeedbackAgent.
            final recommendation =
                (journeyData?['pendingRecommendation'] as String?) ?? 'advance';
            final feedbackPrompt =
                journeyData?['pendingFeedbackPrompt'] as String?;
            final progress = (journeyData?['progress'] as String?) ?? '0%';

            await _journeyAgent.updateLearningJourney(
              journeyId: latestJourneyId,
              userId: userId,
              status: _recommendationToStatus(recommendation),
              progress: progress,
              recommendation: recommendation,
              feedbackText: feedbackPrompt,
              journeyGoal: journeyGoalU.isNotEmpty ? journeyGoalU : null,
              fileParts: fileParts,
            );
            await service.updateLearningJourneyDoc(
              journeyId: latestJourneyId,
              updateData: {
                'pendingRecommendation': FieldValue.delete(),
                'pendingFeedbackPrompt': FieldValue.delete(),
              },
            );

            if (recommendation != 'custom') {
              // Performance summary + confirmation for post-analysis flow.
              final bites = await service.getBiteResultsForJourney(
                  userId, latestJourneyId);
              final biteResults = bites
                  .map((d) => {
                        'title': d['title'] ?? '',
                        'points': d['points'] ?? 0,
                        'maxPoints': d['maxPoints'] ?? 0,
                      })
                  .toList();
              responseText = await _feedbackAgent.confirmationMessage(
                recommendation: recommendation,
                biteResults: biteResults,
                journeyGoal: journeyGoalU,
                history: contentHistory,
              );
            } else {
              responseText =
                  'Neue Lerninhalte nach deinem Wunsch werden erstellt – schau gleich in deine Lernreise!';
            }
          } else {
            // User-initiated adjustment with no prior analysis pending.
            await _journeyAgent.updateLearningJourney(
              journeyId: latestJourneyId,
              userId: userId,
              status: 'custom',
              progress: (journeyData?['progress'] as String?) ?? '0%',
              recommendation: 'custom',
              feedbackText: userMessage,
              journeyGoal: journeyGoalU.isNotEmpty ? journeyGoalU : null,
              fileParts: fileParts,
            );
            responseText =
                'Neue Lerninhalte nach deinem Wunsch werden erstellt – schau gleich in deine Lernreise!';
          }
          journeyId = latestJourneyId;
        } else {
          responseText = await _generalAgent.answer(
            userId: userId,
            message: userMessage,
            history: contentHistory,
          );
        }

      case JourneyIntent(skill: JourneySkill.addBite):
        // User explicitly requests a new bite on a custom topic within the
        // current journey. Appends content without touching status/progress.
        final journeysSnapAB = await service.streamJourneys(sessionId).first;
        if (journeysSnapAB.docs.isNotEmpty) {
          final latestJourneyId = journeysSnapAB.docs.last.id;
          final journeyDataAB = await service.getJourneyById(latestJourneyId);
          final journeyGoalAB =
              (journeyDataAB?['goal'] as String?)?.trim() ?? '';
          await _journeyAgent.addBiteToJourney(
            journeyId: latestJourneyId,
            userId: userId,
            userMessage: userMessage,
            journeyGoal: journeyGoalAB.isNotEmpty ? journeyGoalAB : null,
            fileParts: fileParts,
          );
          responseText =
              'Neue Lerneinheit wurde deiner Lernreise hinzugefügt – schau gleich rein!';
          journeyId = latestJourneyId;
        } else {
          responseText = await _generalAgent.answer(
            userId: userId,
            message: userMessage,
            history: contentHistory,
          );
        }

      // -----------------------------------------------------------------------
      // FeedbackAgent skills
      // -----------------------------------------------------------------------

      case FeedbackIntent(skill: FeedbackSkill.giveFeedback):
        // Present current progress without triggering any journey update.
        final journeysSnapFG = await service.streamJourneys(sessionId).first;
        if (journeysSnapFG.docs.isNotEmpty) {
          final latestJourneyId = journeysSnapFG.docs.last.id;
          responseText = await _feedbackAgent.giveFeedback(
            journeyId: latestJourneyId,
            userId: userId,
            history: contentHistory,
          );
          journeyId = latestJourneyId;
        } else {
          responseText = await _generalAgent.answer(
            userId: userId,
            message: userMessage,
            history: contentHistory,
          );
        }

      case FeedbackIntent(skill: FeedbackSkill.recommend):
        // Analyse results, store a pending recommendation, ask to confirm.
        // Confirmation flows through JourneyIntent(JourneySkill.update).
        final journeysSnapFR = await service.streamJourneys(sessionId).first;
        if (journeysSnapFR.docs.isNotEmpty) {
          final latestJourneyId = journeysSnapFR.docs.last.id;
          responseText = await _feedbackAgent.recommend(
            journeyId: latestJourneyId,
            userId: userId,
            history: contentHistory,
          );
          journeyId = latestJourneyId;
        } else {
          responseText = await _generalAgent.answer(
            userId: userId,
            message: userMessage,
            history: contentHistory,
          );
        }

      // -----------------------------------------------------------------------
      // Single-skill agents
      // -----------------------------------------------------------------------

      case ExplainIntent():
        responseText = await _explainAgent.answer(
          userId: userId,
          unit: userMessage,
          history: contentHistory,
          fileParts: fileParts,
        );

      case HintIntent():
        responseText = await _hintAgent.answer(
          userId: userId,
          question: userMessage,
          history: contentHistory,
          fileParts: fileParts,
        );

      case QuizIntent():
        responseText = await _quizAgent.answer(
          userId: userId,
          unit: userMessage,
          numQuestions: 2,
          history: contentHistory,
          fileParts: fileParts,
        );

      case ReviewIntent():
        responseText = await _reviewAgent.summarize(
          userId: userId,
          sessionTitle: sessionTitle,
          history: contentHistory,
          fileParts: fileParts,
        );

      case GeneralIntent():
        responseText = await _generalAgent.answer(
          userId: userId,
          message: userMessage,
          history: contentHistory,
          fileParts: fileParts,
        );
    }

    // 4. Persist the assistant response.
    await service.addMessage(
      sessionId,
      AiTechMessage(
        role: 'assistant',
        text: responseText,
        ts: DateTime.now(),
        type: intent.storageKey,
        journeyId: journeyId ?? '',
      ),
    );

    return OrchestratorResponse(
      intent: intent,
      message: responseText,
      journeyId: journeyId,
    );
  }

  // ---------------------------------------------------------------------------
  // Feedback loop
  // ---------------------------------------------------------------------------

  /// Call when the user completes all learning bites in [journeyId].
  ///
  /// The [FeedbackAgent] analyses the bite results, stores a pending
  /// recommendation, and posts a feedback message asking the user whether
  /// they want to continue with new content.
  ///
  /// New bites are **not** generated until the user explicitly confirms
  /// (handled via the normal [chat] → [JourneyIntent]/[FeedbackIntent] path).
  Future<void> triggerFeedback({
    required String journeyId,
    required String userId,
    required String sessionId,
  }) async {
    // Load session history so feedback can reference prior conversation.
    final history = await service.getSessionMessages(sessionId);
    final contentHistory = _buildContentHistory(history);

    final feedbackMessage = await _feedbackAgent.recommend(
      journeyId: journeyId,
      userId: userId,
      history: contentHistory,
    );

    await service.addMessage(
      sessionId,
      AiTechMessage(
        role: 'assistant',
        text: feedbackMessage,
        ts: DateTime.now(),
        type: 'feedback.recommend',
        journeyId: journeyId,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Session title generation
  // ---------------------------------------------------------------------------

  /// Maps a FeedbackAgent recommendation string to a journey status value.
  static String _recommendationToStatus(String recommendation) =>
      switch (recommendation) {
        'advance' => 'mastered',
        'repeat' => 'in_progress',
        'review' => 'review',
        _ => 'custom',
      };

  /// Generate a short, descriptive session title (2–5 words, German) from the
  /// user's first message. Returns the original [fallback] if generation fails.
  Future<String> generateSessionTitle(String userMessage,
      {String fallback = ''}) async {
    if (kDebugMode && !kUseRealAiInDebug) return 'Debug-Sitzung';
    try {
      final result = await _generalAgent.generateText(
        'Erstelle einen kurzen, beschreibenden Sitzungstitel (2–5 Wörter, Deutsch) '
        'für die folgende Nutzeranfrage. Nur den Titel, kein weiterer Text.\n'
        'Anfrage: "$userMessage"',
      );
      final title = result.trim();
      return title.isNotEmpty ? title : fallback;
    } catch (_) {
      return fallback;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Maps [AiTechMessage] records to Firebase AI [Content] objects for use
  /// as the `history` parameter in [GenerativeModel.startChat].
  ///
  /// User messages become [Content.text], assistant messages become
  /// [Content.model]. Truncated to the last [_contextWindowSize] turns.
  List<Content> _buildContentHistory(List<AiTechMessage> messages) {
    final recent = messages.length > _contextWindowSize
        ? messages.sublist(messages.length - _contextWindowSize)
        : messages;
    return recent.map((msg) {
      if (msg.role == 'user') {
        return Content.text(msg.text);
      } else {
        return Content.model([TextPart(msg.text)]);
      }
    }).toList();
  }

  /// Serialise the chat history into a plain-text string used by structured
  /// one-shot agents (journey, analyze) that do not use startChat.
  String _buildContextString(List<AiTechMessage> history, String sessionTitle) {
    final buffer = StringBuffer('Session-Thema: $sessionTitle\n');
    final recent = history.length > _contextWindowSize
        ? history.sublist(history.length - _contextWindowSize)
        : history;
    for (final msg in recent) {
      final speaker = msg.role == 'user' ? 'Nutzer' : 'Assistent';
      buffer.writeln('$speaker: ${msg.text}');
    }
    return buffer.toString();
  }
}
