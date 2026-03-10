import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';

class FeedbackAgent extends BaseAgent {
  final AiTechService service;
  FeedbackAgent(this.service);

  // ---------------------------------------------------------------------------
  // Skill: giveFeedback
  // ---------------------------------------------------------------------------

  /// Present the user's current learning performance without triggering a
  /// recommendation or modifying the journey.
  Future<String> giveFeedback({
    required String journeyId,
    required String userId,
    List<Content> history = const [],
  }) async {
    final journeyData = await service.getJourneyById(journeyId);
    final journeyGoal = (journeyData?['goal'] as String?)?.trim() ??
        (journeyData?['context'] as String?)?.trim() ??
        '';
    final bites = await service.getBiteResultsForJourney(userId, journeyId);
    final biteResults = bites
        .map((d) => {
              'title': d['title'] ?? '',
              'points': d['points'] ?? 0,
              'maxPoints': d['maxPoints'] ?? 0,
            })
        .toList();

    if (kDebugMode && !kUseRealAiInDebug) {
      return 'Hier ist dein aktueller Fortschritt. Du machst gute Arbeit!';
    }

    final biteLines = biteResults.isEmpty
        ? 'Noch keine abgeschlossenen Lerneinheiten.'
        : biteResults
            .map((b) =>
                '- ${b['title'] ?? '(ohne Titel)'}: ${b['points'] ?? 0} / ${b['maxPoints'] ?? 0} Punkte')
            .join('\n');
    final subjectLine = journeyGoal.isNotEmpty ? 'Thema: "$journeyGoal"\n' : '';
    final prompt =
        '${subjectLine}Ergebnisse:\n$biteLines\n\nBitte gib eine ehrliche, persönliche Rückmeldung zum aktuellen Lernfortschritt.';

    return await generateTextWithHistory(
      '''
Du bist ein unterstützender Lern-Coach einer Lern-App für Schüler und Studierende.
Deine Aufgabe: Gib dem Lernenden eine ehrliche, motivierende Rückmeldung zu seinem aktuellen Fortschritt.
Nenne konkret, was gut lief und wo noch Übungsbedarf besteht.
Stelle KEINE Frage darüber, ob der Lernende weitermachen möchte – nur reines Feedback.

${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''',
      prompt,
      history: history,
    );
  }

  // ---------------------------------------------------------------------------
  // Skill: recommend
  // ---------------------------------------------------------------------------

  /// Analyse user results for [journeyId] and store the recommendation
  /// without generating new content yet.
  ///
  /// Fetches the journey goal from Firestore so all downstream prompts are
  /// contextualised with the actual subject being learned.
  /// Returns a personalized feedback message that asks the user whether they
  /// want to proceed with the recommendation.
  Future<String> recommend({
    required String journeyId,
    required String userId,
    List<Content> history = const [],
  }) async {
    // 1. Fetch journey metadata for goal/subject context.
    final journeyData = await service.getJourneyById(journeyId);
    final journeyGoal = (journeyData?['goal'] as String?)?.trim() ??
        (journeyData?['context'] as String?)?.trim() ??
        '';

    // 2. Fetch bite results from resumeProgress (contains actual user scores).
    final bites = await service.getBiteResultsForJourney(userId, journeyId);
    final List<Map<String, dynamic>> biteResults = bites
        .map((data) => {
              'title': data['title'] ?? '',
              'points': data['points'] ?? 0,
              'maxPoints': data['maxPoints'] ?? 0,
            })
        .toList();

    // 3. Analyse results to determine next action.
    final String verdict = await analyze(
      biteResults: biteResults,
      journeyGoal: journeyGoal,
    );

    String status = 'awaiting_confirmation';
    String recommendation = 'continue';
    String? feedbackPrompt;
    final subjectHint =
        journeyGoal.isNotEmpty ? ' zum Thema "$journeyGoal"' : '';

    if (verdict.startsWith('custom:')) {
      recommendation = verdict.substring(7).trim();
      feedbackPrompt = recommendation;
    } else if (verdict.contains('advance')) {
      recommendation = 'advance';
      feedbackPrompt =
          'Der Lernende hat die aktuellen Inhalte$subjectHint sehr gut gemeistert. '
          'Führe das nächste logische Konzept ein und steigere den Schwierigkeitsgrad. '
          'Baue auf dem gelernten Stoff auf.';
    } else if (verdict.contains('repeat')) {
      recommendation = 'repeat';
      feedbackPrompt = 'Der Lernende übt noch$subjectHint. '
          'Erstelle abwechslungsreiche Wiederholungsaufgaben zum selben Konzept '
          'mit anderen Beispielen und verschiedenen Aufgabenformaten. '
          'Erkläre unsichere Stellen auf eine alternative, anschaulichere Weise.';
    } else if (verdict.contains('review')) {
      recommendation = 'review';
      feedbackPrompt =
          'Der Lernende hat Schwierigkeiten mit den Grundlagen$subjectHint. '
          'Gehe einen Schritt zurück und erkläre die fundamentalen Konzepte erneut, '
          'einfacher und mit mehr Analogien und Schritt-für-Schritt-Erklärungen.';
    }

    // 4. Store the pending recommendation on the journey doc — do NOT
    //    generate new content yet. The user must confirm first.
    await service.updateLearningJourneyDoc(
      journeyId: journeyId,
      updateData: {
        'status': status,
        'pendingRecommendation': recommendation,
        'pendingFeedbackPrompt': feedbackPrompt,
        'updatedAt': DateTime.now(),
      },
    );

    // 5. Generate a personalized feedback message that asks whether to proceed.
    return await generateFeedbackMessage(
      verdict: verdict,
      biteResults: biteResults,
      journeyGoal: journeyGoal,
      history: history,
    );
  }

  // ---------------------------------------------------------------------------
  // Skill: confirmationMessage (used by orchestrator after journey update)
  // ---------------------------------------------------------------------------

  /// Generates a confirmation message after [LearningJourneyAgent] has
  /// executed a pending recommendation. Combines genuine performance feedback
  /// with the confirmation that new content is on its way.
  Future<String> confirmationMessage({
    required String recommendation,
    required List<Map<String, dynamic>> biteResults,
    required String journeyGoal,
    List<Content> history = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return '**Super, auf geht\'s!** Hier ist dein Feedback zu den letzten Aufgaben – '
          'danach warten schon neue Inhalte auf dich.\n\n'
          'Neue Lerninhalte werden jetzt erstellt – schau gleich in deine Lernreise!';
    }
    final biteLines = biteResults
        .map((b) =>
            '- ${b['title'] ?? '(ohne Titel)'}: ${b['points'] ?? 0} / ${b['maxPoints'] ?? 0} Punkte')
        .join('\n');
    final subjectLine = journeyGoal.isNotEmpty ? 'Thema: "$journeyGoal"\n' : '';
    final recommendationDesc = switch (recommendation) {
      'advance' =>
        'Der Lernende hat sehr gut abgeschnitten und erhält jetzt schwierigere Inhalte.',
      'repeat' => 'Der Lernende übt weiter am selben Stoff mit neuen Aufgaben.',
      'review' =>
        'Der Lernende wiederholt die Grundlagen mit einfacheren Erklärungen.',
      _ => 'Der Lernende erhält neue Inhalte nach seinem Wunsch.',
    };
    final prompt = '''
${subjectLine}Ergebnisse:
$biteLines

Empfehlung: $recommendationDesc

Der Lernende hat gerade bestätigt, weiterzumachen. Neue Inhalte werden bereits erstellt.
Bitte erstelle jetzt:
1. Eine kurze, ehrliche Rückmeldung zu den obigen Ergebnissen (1–2 Sätze, motivierend)
2. Einen positiven Abschlusssatz, der bestätigt, dass die neuen Inhalte bereitstehen

Kein weiterer Frageblock – der Lernende hat bereits bestätigt.''';
    return await generateTextWithHistory(
      '''
Du bist ein unterstützender Lern-Coach einer Lern-App für Schüler und Studierende.
Gib dem Lernenden eine kurze, motivierende Rückmeldung zu seinem Abschnitt und bestätige, dass neue Inhalte für ihn erstellt werden.
Keine Fragen mehr stellen – der Lernende hat bereits zugestimmt.

${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''',
      prompt,
      history: history,
    );
  }

  /// Generate a personalized, conversational feedback message for the user
  /// based on their bite results, the verdict, and the prior chat history.
  Future<String> generateFeedbackMessage({
    required String verdict,
    required List<Map<String, dynamic>> biteResults,
    required String journeyGoal,
    List<Content> history = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return '**Super gemacht!** Du hast die Grundlagen gut verstanden. '
          'Ich habe neue Inhalte für dich vorbereitet, die auf deinem '
          'bisherigen Wissen aufbauen – schau mal rein!\n\n'
          'Möchtest du mit neuen Lerninhalten weitermachen?';
    }
    final prompt = _buildFeedbackMessagePrompt(
      verdict: verdict,
      biteResults: biteResults,
      journeyGoal: journeyGoal,
    );
    return await generateTextWithHistory(
      _buildFeedbackMessageSystemPrompt(),
      prompt,
      history: history,
    );
  }

  String _buildFeedbackMessageSystemPrompt() {
    return '''
Du bist ein unterstützender Lern-Coach einer Lern-App für Schüler und Studierende.
Deine Aufgabe: Gib dem Lernenden nach dem Abschluss eines Lernabschnitts eine kurze, motivierende und ehrliche Rückmeldung zu seinem Fortschritt.
Berücksichtige den bisherigen Gesprächsverlauf, um die Rückmeldung persönlich und kontextuell passend zu gestalten.

Struktur:
1. Kurze persönliche Einschätzung des Fortschritts (1–2 Sätze, ehrlich aber motivierend)
2. Was gut lief oder wo noch Übungsbedarf besteht (konkret, ohne zu verallgemeinern)
3. Ein kurzer Ausblick: Was als nächstes empfohlen wird
4. Abschließende Frage, ob der Lernende mit neuen Inhalten weitermachen möchte (z.B. "Möchtest du mit neuen Lerninhalten weitermachen?")

Wichtig: Generiere KEINE neuen Inhalte. Frage den Lernenden zuerst, ob er fortfahren möchte.

${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''';
  }

  String _buildFeedbackMessagePrompt({
    required String verdict,
    required List<Map<String, dynamic>> biteResults,
    required String journeyGoal,
  }) {
    final bites = biteResults
        .map((b) =>
            '- ${b['title'] ?? '(ohne Titel)'}: ${b['points'] ?? 0} / ${b['maxPoints'] ?? 0} Punkte')
        .join('\n');
    final subjectLine = journeyGoal.isNotEmpty ? 'Thema: "$journeyGoal"\n' : '';
    final verdictDesc = switch (verdict) {
      String v when v.contains('advance') =>
        'Der Lernende hat sehr gut abgeschnitten und ist bereit für den nächsten Schritt.',
      String v when v.contains('repeat') =>
        'Der Lernende hat gemischte Ergebnisse und braucht weitere Übung mit dem aktuellen Stoff.',
      String v when v.contains('review') =>
        'Der Lernende hat Schwierigkeiten und sollte die Grundlagen nochmals wiederholen.',
      _ => 'Der Lernende hat eine individuelle Lernreise erhalten.',
    };
    return '''
${subjectLine}Ergebnisse:
$bites

Bewertung: $verdictDesc

Bitte erstelle jetzt die persönliche Rückmeldung für den Lernenden.''';
  }

  /// Analyse bite-level results and return one of: review, repeat, advance, custom:<text>.
  Future<String> analyze({
    required List<Map<String, dynamic>> biteResults,
    String? journeyGoal,
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return 'advance';
    }
    final prompt = _buildPrompt(biteResults, journeyGoal: journeyGoal);
    return await generateText(prompt);
  }

  String _buildPrompt(
    List<Map<String, dynamic>> biteResults, {
    String? journeyGoal,
  }) {
    final bites = biteResults
        .map((b) =>
            '- ${b['title'] ?? '(ohne Titel)'}: ${b['points'] ?? 0} / ${b['maxPoints'] ?? 0} Punkte')
        .join('\n');
    final subjectLine = journeyGoal != null && journeyGoal.isNotEmpty
        ? '\nLernbereich: "$journeyGoal"'
        : '';
    return '''
Du bist ein Lernfortschritts-Analysator.$subjectLine
Analysiere die Ergebnisse der Learning Bites und entscheide, was als nächstes empfohlen werden soll.

Ergebnisse:
$bites

Regeln:
- "review"     → Mehrere Bites sehr schwach (≤ 50 %) oder große Wissenslücken erkennbar
- "repeat"     → Gemischte Ergebnisse (50–80 %), Übung nötig
- "advance"    → Starke Leistung (> 80 %), bereit für den nächsten Schritt
- "custom:<text>" → Wenn eine spezifische Empfehlung sinnvoller ist (z.B. "custom: Übe gezielt Schleifen")

Antworte NUR mit dem Schlüsselwort (review, repeat, advance oder custom:<text>). Kein weiterer Text.
''';
  }
}
