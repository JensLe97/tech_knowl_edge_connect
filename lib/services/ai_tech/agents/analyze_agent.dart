import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/agent_task.dart';

class AnalyzeAgent extends BaseAgent {
  /// Analyse [userMessage] and return a typed [AgentIntent] that identifies
  /// both the agent and the specific skill to invoke within it.
  ///
  /// [history] is the prior conversation so the router can resolve
  /// follow-up references like "das als Quiz" or "erkläre das nochmal".
  Future<AgentIntent> analyze(
    String userMessage, {
    List<Content> history = const [],
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return const JourneyIntent(JourneySkill.create);
    }
    final responseText = await generateTextWithHistory(
      _buildSystemPrompt(),
      userMessage,
      history: history,
      fileParts: fileParts,
    );
    final verdict = responseText.trim().toLowerCase();

    // Check compound keywords before prefix-only matches to avoid collisions.
    if (verdict.contains('journey.addbite')) {
      return const JourneyIntent(JourneySkill.addBite);
    }
    if (verdict.contains('journey.create')) {
      return const JourneyIntent(JourneySkill.create);
    }
    if (verdict.contains('journey.update')) {
      return const JourneyIntent(JourneySkill.update);
    }
    if (verdict.contains('feedback.give')) {
      return const FeedbackIntent(FeedbackSkill.giveFeedback);
    }
    if (verdict.contains('feedback.recommend')) {
      return const FeedbackIntent(FeedbackSkill.recommend);
    }
    if (verdict.contains('hint')) return const HintIntent();
    if (verdict.contains('quiz')) return const QuizIntent();
    if (verdict.contains('review')) return const ReviewIntent();
    if (verdict.contains('explain')) return const ExplainIntent();
    return const GeneralIntent();
  }

  String _buildSystemPrompt() {
    return '''
Du bist der Routing-Agent einer KI-gestützten Lern-App für Schüler und Studierende.
Deine einzige Aufgabe: Weise die aktuelle Nutzer-Nachricht dem passenden Agenten und seinem Skill zu.
Berücksichtige den bisherigen Gesprächsverlauf, um Bezüge wie "das" oder "nochmal" korrekt aufzulösen.

Auswahlregeln:
- journey.create      → Nutzer möchte ein neues Thema lernen oder eine neue Lernreise starten ("Ich will X lernen", "Erkläre mir X von Grund auf", "Starte eine Lernreise über X")
- journey.addBite     → Nutzer ist in einer aktiven Lernreise und nennt EXPLIZIT ein konkretes neues Thema oder Konzept, das als zusätzliche Lerneinheit ergänzt werden soll – entscheidendes Merkmal: ein SPEZIFISCHES THEMA wird genannt UND die Absicht ist Hinzufügen, nicht Anpassen ("Füge eine Einheit über Rekursion hinzu", "Ich will auch Pointer lernen", "Ergänze meine Lernreise um Sortieralgorithmen", "Noch eine Aufgabe zu Big-O-Notation", "Kannst du etwas über X ergänzen?")
- journey.update      → Nutzer reagiert auf eine Empfehlung ODER passt Schwierigkeit/Tempo/Richtung an, OHNE ein konkretes neues Thema zu nennen ("zu einfach", "zu schwer", "anderes Thema", "Ja weiter", "Nächstes Thema", "Gerne", "Machen wir", "Weiter lernen", "Ja bitte", "langsamer bitte", "das war zu viel auf einmal")

Entscheidungsregel journey.addBite vs. journey.update:
  → Wird ein KONKRETES THEMA / KONZEPT genannt, das NEU hinzugefügt werden soll? → journey.addBite
  → Bestätigt der Nutzer eine Empfehlung oder passt er Schwierigkeit/Pace an (kein neues spezifisches Thema)? → journey.update
- feedback.give       → Nutzer möchte seinen aktuellen Lernfortschritt oder seine Leistung einschätzen ("Wie gut war ich?", "Was ist mein Fortschritt?", "Wo stehe ich gerade?")
- feedback.recommend  → Nutzer fragt nach einer Empfehlung, was er als nächstes lernen soll ("Was soll ich als nächstes tun?", "Was empfiehlst du mir?")
- explain             → Nutzer bittet um eine sofortige, kurze Erklärung eines konkreten Begriffs (kein ganzes Thema)
- hint                → Nutzer steckt bei einer Aufgabe fest und sucht einen Denkanstoss
- quiz                → Nutzer möchte sein Wissen testen oder ein Quiz starten
- review              → Nutzer möchte Gelerntes zusammenfassen oder wiederholen
- general             → Smalltalk, Dankesnachricht, organisatorisches, Ablehnung ("Nein danke", "Nicht jetzt") oder alles ohne klares Lernziel

Wichtig: Antworte NUR mit einem einzigen Schlüssel aus der Liste (journey.create, journey.addBite, journey.update, feedback.give, feedback.recommend, explain, hint, quiz, review oder general). Kein weiterer Text. Wenn du zwischen journey.addBite und journey.update zweifelst: Nenne-ein-Thema → addBite, kein-spezifisches-Thema → update.
''';
  }
}
