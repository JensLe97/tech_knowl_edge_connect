import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';

class ReviewAgent extends BaseAgent {
  Future<String> summarize({
    required String userId,
    required String sessionTitle,
    List<Content> history = const [],
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return '## Zusammenfassung: $sessionTitle\n\n'
          '**Was du gelernt hast:**\n'
          '- Kernkonzepte und grundlegende Definitionen\n'
          '- Praktische Anwendungsbeispiele\n'
          '- Wichtige Zusammenhänge\n\n'
          '**Tipp:** Starte eine Lernreise, um dein Wissen mit interaktiven Aufgaben zu festigen!';
    }
    return await generateTextWithHistory(
      _buildSystemPrompt(sessionTitle),
      'Bitte erstelle eine Zusammenfassung des bisherigen Gesprächs.',
      history: history,
      fileParts: fileParts,
    );
  }

  String _buildSystemPrompt(String sessionTitle) {
    return '''
Du bist ein Zusammenfassungs-Agent einer Lern-App für Schüler und Studierende.
Der Lernende möchte das Besprochene rekapitulieren. Erstelle eine strukturierte Zusammenfassung des bisherigen Gesprächsverlaufs zum Thema "${sessionTitle.isNotEmpty ? sessionTitle : 'diesem Thema'}".

Struktur deiner Antwort:
1. Kurze Überschrift mit dem Hauptthema
2. Bullet-Liste der wichtigsten Konzepte und Erkenntnisse aus dem Gespräch
3. Ein bis zwei Sätze: Was der Lernende mitnehmen sollte
4. Optional: Hinweis auf offene Fragen oder nächste Lernschritte

Halte dich an den tatsächlichen Gesprächsinhalt – erfinde keine Themen.
${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''';
  }
}
