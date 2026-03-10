import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';

class GeneralPurposeAgent extends BaseAgent {
  Future<String> answer({
    required String userId,
    required String message,
    List<Content> history = const [],
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return 'Das ist eine interessante Frage! Im Debug-Modus antworte ich mit einer Beispielantwort.\n\n'
          'Deine Nachricht "$message" wurde empfangen. In der Produktion würde hier eine '
          'KI-generierte, auf deinen Kontext zugeschnittene Antwort erscheinen.';
    }
    return await generateTextWithHistory(
      _buildSystemPrompt(),
      message,
      history: history,
      fileParts: fileParts,
    );
  }

  String _buildSystemPrompt() {
    return 'Beantworte die Nachrichten des Lernenden freundlich und hilfreich.\n'
        '${AiTechPrompts.markdownStyling}'
        '${AiTechPrompts.generalInstructions}';
  }
}
