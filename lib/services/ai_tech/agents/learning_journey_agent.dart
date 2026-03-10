import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';

class LearningJourneyAgent extends BaseAgent {
  final AiTechService aiTechService;
  final AiTechGenService aiTechGenService = AiTechGenService();
  LearningJourneyAgent(this.aiTechService);

  /// Generates a learning journey and learning bites for the user, using user message as context
  Future<String> createLearningJourney({
    required String userId,
    required String sessionId,
    required String goal,
    required List<String> preferredSubjects,
    int length = 2,
    String? additionalText,
    String? userMessage,
    String? context,
    List<Part> fileParts = const [],
  }) async {
    // 1. Analyze user message to derive a precise generation instruction
    //    including the concept to start with and the difficulty/style.
    String analyzedInstruction = '';
    if (userMessage != null && userMessage.trim().isNotEmpty) {
      analyzedInstruction = await analyze(
        userMessage: userMessage,
        goal: goal,
        context: context,
      );
    }

    // 2. Create journey doc with user context
    final journeyId = 'journey_${DateTime.now().millisecondsSinceEpoch}';
    await aiTechService.createLearningJourneyDoc(
      journeyId: journeyId,
      userId: userId,
      sessionId: sessionId,
      goal: goal,
      preferredSubjects: preferredSubjects,
      length: length,
      userMessage: userMessage,
      instruction: analyzedInstruction.isNotEmpty ? analyzedInstruction : null,
      context: context,
    );

    // 3. Generate learning bites – include BOTH the analyzed instruction and
    //    the original user message so the gen service has full picture.
    final learningBites = await aiTechGenService.generateLearningBites(
      instruction: analyzedInstruction.isNotEmpty
          ? analyzedInstruction
          : (additionalText ?? goal),
      userMessage: userMessage,
      subject: goal,
      fileParts: fileParts,
      useGoogleSearchTool: true,
      minBites: length,
      maxBites: length + 1,
    );

    // 4. For each bite generate tasks in parallel; pass bite title + subject for context.
    await Future.wait(learningBites.map((bite) async {
      final tasks = await aiTechGenService.generateLearningBiteTasks(
        additionalText:
            bite.content.isNotEmpty ? bite.content.join('\n') : bite.name,
        biteTitle: bite.name,
        subject: goal,
        fileParts: fileParts,
        useGoogleSearchTool: true,
      );
      await aiTechService.addLearningBiteWithTasks(
        journeyId: journeyId,
        bite: bite.toMap(),
        tasks: tasks.map((t) => t.toMap()).toList(),
        userId: userId,
      );
    }));

    return journeyId;
  }

  /// Updates a learning journey with feedback and generates new content.
  Future<void> updateLearningJourney({
    required String journeyId,
    required String userId,
    required String status,
    required String progress,
    required String recommendation,
    String? feedbackText,
    String? journeyGoal,
    List<String>? upcomingTasks,
    List<Part> fileParts = const [],
  }) async {
    // Derive a new generation instruction from feedback + recommendation.
    String? newInstruction;
    if ((feedbackText != null && feedbackText.isNotEmpty) ||
        (upcomingTasks != null && upcomingTasks.isNotEmpty)) {
      newInstruction = await reactOnFeedback(
        feedback: feedbackText,
        recommendation: recommendation,
        journeyGoal: journeyGoal,
        upcomingTasks: upcomingTasks,
      );
    }

    final updateData = <String, dynamic>{
      'status': status,
      'progress': progress,
      'recommendation': recommendation,
      'updatedAt': DateTime.now(),
      if (feedbackText != null) 'lastFeedback': feedbackText,
      if (newInstruction != null && newInstruction.isNotEmpty)
        'instruction': newInstruction,
    };
    await aiTechService.updateLearningJourneyDoc(
      journeyId: journeyId,
      updateData: updateData,
    );

    final instruction = newInstruction ?? feedbackText;
    if (instruction != null && instruction.isNotEmpty) {
      final learningBites = await aiTechGenService.generateLearningBites(
        instruction: instruction,
        subject: journeyGoal,
        fileParts: fileParts,
        useGoogleSearchTool: true,
        minBites: 1,
        maxBites: 1,
      );
      await Future.wait(learningBites.map((bite) async {
        final tasks = await aiTechGenService.generateLearningBiteTasks(
          additionalText:
              bite.content.isNotEmpty ? bite.content.join('\n') : bite.name,
          biteTitle: bite.name,
          subject: journeyGoal,
          fileParts: fileParts,
          useGoogleSearchTool: true,
        );
        await aiTechService.addLearningBiteWithTasks(
          journeyId: journeyId,
          bite: bite.toMap(),
          tasks: tasks.map((t) => t.toMap()).toList(),
          userId: userId,
        );
      }));
    }
  }

  /// Appends one new learning bite (+ tasks) to an existing journey based on
  /// the user's explicit topic request.
  Future<void> addBiteToJourney({
    required String journeyId,
    required String userId,
    required String userMessage,
    String? journeyGoal,
    List<Part> fileParts = const [],
  }) async {
    // Turn the raw user request into a focused generation instruction.
    final instruction = await analyze(
      userMessage: userMessage,
      goal: journeyGoal,
    );

    final learningBites = await aiTechGenService.generateLearningBites(
      instruction: instruction,
      userMessage: userMessage,
      subject: journeyGoal ?? userMessage,
      fileParts: fileParts,
      useGoogleSearchTool: true,
      minBites: 1,
      maxBites: 1,
    );

    await Future.wait(learningBites.map((bite) async {
      final tasks = await aiTechGenService.generateLearningBiteTasks(
        additionalText:
            bite.content.isNotEmpty ? bite.content.join('\n') : bite.name,
        biteTitle: bite.name,
        subject: journeyGoal ?? userMessage,
        fileParts: fileParts,
        useGoogleSearchTool: true,
      );
      await aiTechService.addLearningBiteWithTasks(
        journeyId: journeyId,
        bite: bite.toMap(),
        tasks: tasks.map((t) => t.toMap()).toList(),
        userId: userId,
      );
    }));
  }

  // ---------------------------------------------------------------------------
  // Prompt builders
  // ---------------------------------------------------------------------------

  /// Builds the analyze prompt that turns a raw user message into a
  /// precise generation instruction (concept, difficulty, style).
  String _buildPrompt(String userMessage, {String? goal, String? context}) {
    final goalLine = goal != null && goal.isNotEmpty
        ? '\nLernbereich (Session-Titel): "$goal"'
        : '';
    final contextBlock = context != null && context.isNotEmpty
        ? '\nBisheriger Sitzungsverlauf (zur Orientierung):\n$context'
        : '';
    return '''
Du bist ein Lernreise-Planer für eine Bildungs-App.
Deine Aufgabe: Analysiere die Nutzer-Nachricht und erstelle eine präzise Generierungs-Anweisung für den Content-Agenten, der die Learning Bites erstellen soll.$goalLine$contextBlock

Die Anweisung muss drei Dinge festlegen:
1. Einstiegs-Konzept: Welches konkrete Unterthema soll als erstes behandelt werden? (z.B. für "Python lernen" → "Variablen und Datentypen")
2. Schwierigkeitsniveau: Aus der Nutzer-Nachricht ableiten – "ich möchte lernen" / "Einführung" → Anfänger; "vertiefen" / "auffrischen" → Fortgeschrittene
3. Lernstil (falls erkennbar): z.B. "viele Codebeispiele", "Theorie mit Analogien", "praxisorientiert"

Formuliere 2–3 Sätze, direkt an den Content-Agenten gerichtet (Imperativ, Du-Form an den Agenten).
Keine Einleitung, keine Erklärung – nur die fertige Anweisung.

Nutzer-Nachricht: "$userMessage"
''';
  }

  /// Builds the feedback-loop prompt that turns a verdict into an instruction
  /// for the NEXT set of learning bites.
  String _buildFeedbackPrompt({
    String? feedback,
    required String recommendation,
    String? journeyGoal,
    List<String>? upcomingTasks,
  }) {
    final goalLine = journeyGoal != null && journeyGoal.isNotEmpty
        ? '\nLernbereich: "$journeyGoal"'
        : '';
    final completedLine = upcomingTasks != null && upcomingTasks.isNotEmpty
        ? '\nAbgeschlossene Konzepte: ${upcomingTasks.join(", ")}'
        : '';
    final feedbackLine =
        feedback != null && feedback.isNotEmpty ? '\nKontext: $feedback' : '';

    return '''
Du bist ein Lernreise-Planer für eine Bildungs-App.
Der Lernende hat Lerninhalte abgeschlossen. Erstelle eine neue Generierungs-Anweisung für den nächsten Schritt.$goalLine$completedLine$feedbackLine
Bewertung des Feedback-Agenten: "$recommendation"

Verhalte dich je nach Bewertung:
- "advance"  → Führe das nächste logische Konzept des Themenbereichs ein (aufbauend, etwas anspruchsvoller)
- "repeat"   → Erstelle variierte Wiederholungsaufgaben zum selben Konzept mit anderen Beispielen und Formaten
- "review"   → Gehe einen Schritt zurück; erkläre Grundlagen einfacher, mit mehr Analogien und Schritt-für-Schritt-Anleitungen
- "custom:…" → Folge der spezifischen Empfehlung nach dem Doppelpunkt

Formuliere 2–3 Sätze, direkt an den Content-Agenten gerichtet (Imperativ). Keine Einleitung – nur die fertige Anweisung.
''';
  }

  // ---------------------------------------------------------------------------
  // Analysis helpers
  // ---------------------------------------------------------------------------

  /// Analyze [userMessage] and return a focused generation instruction.
  ///
  /// [goal] is the session title (e.g. "Python").
  /// [context] is the rolling chat history for additional orientation.
  Future<String> analyze({
    required String userMessage,
    String? goal,
    String? context,
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return 'Beginne mit "Variablen und Datentypen" – erkläre Konzept und Syntax '
          'für Anfänger mit konkreten Python-Codebeispielen. '
          'Baue jeden Bite auf dem vorherigen auf und steigere die Komplexität schrittweise.';
    }
    final prompt = _buildPrompt(userMessage, goal: goal, context: context);
    final responseText = await generateText(prompt);
    return responseText.trim();
  }

  /// Adapt the journey instruction based on feedback results verdict.
  Future<String> reactOnFeedback({
    String? feedback,
    required String recommendation,
    String? journeyGoal,
    List<String>? upcomingTasks,
  }) async {
    final prompt = _buildFeedbackPrompt(
      feedback: feedback,
      recommendation: recommendation,
      journeyGoal: journeyGoal,
      upcomingTasks: upcomingTasks,
    );
    final responseText = await generateText(prompt);
    return responseText.trim();
  }
}
