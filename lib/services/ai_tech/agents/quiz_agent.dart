import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';

class QuizAgent extends BaseAgent {
  Future<String> answer({
    required String userId,
    required String unit,
    int numQuestions = 3,
    List<Content> history = const [],
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return '**Quiz: $unit**\n\n'
          '**Frage 1 (leicht):** Was ist das Hauptziel von $unit?\n'
          '*Antwort:* Es dient dazu, Probleme strukturiert und effizient zu lösen.\n\n'
          '**Frage 2 (mittel):** Welches Szenario beschreibt einen typischen Anwendungsfall?\n'
          '*Antwort:* Wenn du Daten verarbeitest und das Ergebnis weiterverwendest.\n\n'
          '**Frage 3 (anspruchsvoll):** Wahr oder Falsch – $unit kann immer ohne Nebeneffekte eingesetzt werden?\n'
          '*Antwort:* Falsch – es kommt auf den Kontext und die Implementierung an.';
    }
    return await generateTextWithHistory(
      _buildSystemPrompt(numQuestions),
      unit,
      history: history,
      fileParts: fileParts,
    );
  }

  String _buildSystemPrompt(int numQuestions) {
    return '''
Du bist ein Quiz-Agent in einer Lern-App. Erstelle $numQuestions abwechslungsreiche Quizfragen zu dem vom Lernenden genannten Thema.

Anforderungen:
- Variiere die Schwierigkeit (einfach → mittel → anspruchsvoll)
- Decke unterschiedliche Aspekte des Themas ab
- Füge nach jeder Frage die korrekte Antwort und eine kurze Begründung (1 Satz) ein
- Nutze verschiedene Frageformate (Verständnisfrage, Szenario, Wahr/Falsch, Lückentext)

${AiTechPrompts.markdownStyling}${AiTechPrompts.chatTone}''';
  }
}
