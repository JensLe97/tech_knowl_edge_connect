import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

/// Set to `true` to call Firebase AI even when running in debug mode.
/// When `false` (default), all agents return fast mock responses in debug.
const bool kUseRealAiInDebug = false;

/// The Gemini model used by all AI agents. Change here to switch globally.
const String kDefaultAiModel = 'gemini-2.5-flash';

/// A base abstract class for all AI agents, providing shared initialization
/// and helper methods to reduce code duplication and improve testability.
abstract class BaseAgent {
  final FirebaseAI _firebaseAI;

  BaseAgent({FirebaseAI? firebaseAI})
      : _firebaseAI = firebaseAI ??
            FirebaseAI.googleAI(appCheck: FirebaseAppCheck.instance);

  /// Shared helper to generate base text content (single-shot, no history).
  Future<String> generateText(String prompt,
      {String modelName = kDefaultAiModel}) async {
    final model = _firebaseAI.generativeModel(model: modelName);
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Chat-based helper that sends [userMessage] into a multi-turn session.
  ///
  /// [systemPrompt] becomes the model's system instruction.
  /// [history] is the prior conversation loaded from Firestore, mapped to
  /// [Content] objects (user turns via [Content.text], model turns via
  /// [Content.model]).
  Future<String> generateTextWithHistory(
    String systemPrompt,
    String userMessage, {
    List<Content> history = const [],
    List<Part> fileParts = const [],
    String modelName = kDefaultAiModel,
  }) async {
    final model = _firebaseAI.generativeModel(
      model: modelName,
      systemInstruction: Content.system(systemPrompt),
    );
    final chat = model.startChat(history: history);
    final Content userContent = fileParts.isEmpty
        ? Content.text(userMessage)
        : Content.multi([TextPart(userMessage), ...fileParts]);
    final response = await chat.sendMessage(userContent);
    return response.text ?? '';
  }
}
