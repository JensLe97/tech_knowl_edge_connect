import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';

class ExplainAgent extends BaseAgent {
  Future<String> answer({
    required String userId,
    required String unit,
    List<Content> history = const [],
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return '**$unit** ist ein grundlegendes Konzept in der Programmierung.\n\n'
          '**Kernidee:** Es ermöglicht dir, Daten strukturiert zu speichern und wiederzuverwenden.\n\n'
          '**Beispiel:** Stell dir eine Variable wie eine beschriftete Schachtel vor – du legst etwas rein und holst es später wieder heraus.\n\n'
          '**Zusammenfassung:** Mit diesem Konzept kannst du Programme effizienter und lesbarer gestalten.';
    }
    return await generateTextWithHistory(
      _buildSystemPrompt(),
      unit,
      history: history,
      fileParts: fileParts,
    );
  }

  String _buildSystemPrompt() {
    return '''
Du bist ein Erklärungs-Agent einer Lern-App für Schüler und Studierende.
Erkläre das vom Lernenden genannte Konzept klar, prägnant und verständlich.

Struktur deiner Antwort:
1. Eine Ein-Satz-Definition in eigenen Worten
2. Kernidee / Intuition (warum ist das wichtig, wie hängt es mit dem Thema zusammen?)
3. Konkretes Beispiel oder Analogie zum Anfassen
4. Kurze Zusammenfassung (1–2 Sätze)

${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''';
  }
}
