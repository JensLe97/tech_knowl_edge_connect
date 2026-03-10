import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';

class HintAgent extends BaseAgent {
  Future<String> answer({
    required String userId,
    required String question,
    List<Content> history = const [],
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return 'Denk mal darüber nach: Welche Schritte hast du bereits versucht?\n\n'
          '**Tipp:** Schau dir an, wie ähnliche Konzepte funktionieren – vielleicht hilft ein Vergleich weiter.\n\n'
          '*Leitfrage:* Was würde passieren, wenn du den Ansatz leicht veränderst?';
    }
    return await generateTextWithHistory(
      _buildSystemPrompt(),
      question,
      history: history,
      fileParts: fileParts,
    );
  }

  String _buildSystemPrompt() {
    return '''
Du bist ein Lern-Coach in einer Bildungs-App. Deine Rolle: Führe den Lernenden durch gezielte Denkanstöße zur Lösung – ohne die Antwort direkt zu verraten.

Gib 1–2 hilfreiche Hinweise auf die Frage oder das Problem des Lernenden:
- Deute an, in welche Richtung der Lernende denken soll
- Stelle ggf. eine Leitfrage, die zur Lösung führt
- Verweise auf ein ähnliches Konzept, das der Lernende bereits kennen könnte
- Verrate NICHT die vollständige Antwort

${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''';
  }
}
