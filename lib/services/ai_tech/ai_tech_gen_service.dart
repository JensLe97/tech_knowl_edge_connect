import 'dart:async';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_knowledge_check_answer_feedback.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_knowledge_check_prompt.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart' as tk;
import 'package:tech_knowl_edge_connect/models/learning/task_type.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/prompts/ai_tech_prompts.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/base_agent.dart';

class AiTechGenService {
  static const String _markdownStyling = AiTechPrompts.markdownStyling;
  static const String _generalInstructions = AiTechPrompts.generalInstructions;
  // --- AI Tech Generation ---

  Stream<GenerateContentResponse> summarizeMultipleData({
    List<Part> fileParts = const [],
    String? additionalText,
    bool splitIntoParts = false,
  }) async* {
    GenerationConfig? generationConfig;
    final buffer = StringBuffer(
      "Fasse die wichtigsten Punkte dieser Dateien und Texte zusammen. ",
    );

    if (splitIntoParts) {
      final summarySchema = Schema.object(
        properties: {'parts': Schema.array(items: Schema.string())},
      );
      generationConfig = GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: summarySchema,
      );
      buffer.write(
        "Teile die Zusammenfassung in mehrere Abschnitte (Parts) auf, die nacheinander gelesen werden können. "
        "Jeder Abschnitt soll einen klaren Gedanken oder Aspekt behandeln. "
        "Z.B. könnte sich jeder Abschnitt auf ein bestimmtes Dokument oder einen bestimmten Themenbereich beziehen. "
        "Achte darauf, dass die Abschnitte inhaltlich sinnvoll aufgeteilt sind und nicht zu lang oder zu kurz sind. "
        "Nutze keine horizontale Trennlinien, um die Abschnitte zu trennen, sondern um Themen innerhalb eines Abschnitts zu strukturieren. "
        "Antworte im JSON-Format: {'parts': ['Abschnitt 1', 'Abschnitt 2', ...]}",
      );
    }

    buffer.write(
      "Erstelle eine übersichtliche Zusammenfassung in deutscher Sprache, "
      "sodass sie zum Lernen und schnellen Verstehen der Inhalte geeignet ist. "
      "Die Zusammenfassung soll im Markdown-Format sein, damit sie später gut dargestellt werden können. "
      "$_markdownStyling"
      "$_generalInstructions",
    );

    final model =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: kDefaultAiModel,
          generationConfig: generationConfig,
        );
    final prompt = TextPart(buffer.toString());

    final List<Part> parts = [prompt];
    parts.addAll(fileParts);
    if (additionalText != null && additionalText.isNotEmpty) {
      parts.add(TextPart("Zusätzlicher Textinhalt: $additionalText"));
    }
    final response = model.generateContentStream([Content.multi(parts)]);
    yield* response;
  }

  Future<List<LearningBite>> generateLearningBites({
    required String instruction,
    String? userMessage,
    String? subject,
    String additionalText = '',
    List<Part> fileParts = const [],
    bool useGoogleSearchTool = false,
    int minBites = 2,
    int maxBites = 3,
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      // Return dummy learning bites for testing
      return List.generate(
        minBites,
        (index) => LearningBite(
          id: 'debug_bite_$index',
          name: 'Learning Bite ${index + 1}',
          type: 'lesson',
          content: [
            'Inhaltspunkt 1 für Learning Bite ${index + 1}',
            'Inhaltspunkt 2 für Learning Bite ${index + 1}',
          ],
        ),
      );
    }

    // Define the JSON schema for a list of learning bites
    final learningBiteSchema = Schema.object(
      properties: {
        'learningBites': Schema.array(
          items: Schema.object(
            properties: {
              'title': Schema.string(),
              'type': Schema.string(),
              'content': Schema.array(items: Schema.string()),
              'completed': Schema.boolean(),
              'iconData': Schema.object(
                properties: {
                  'codePoint': Schema.integer(),
                  'fontFamily': Schema.string(),
                  'fontPackage': Schema.string(),
                },
                optionalProperties: ['fontFamily', 'fontPackage'],
              ),
              'authorId': Schema.string(),
              'status': Schema.string(),
            },
            optionalProperties: ['completed', 'iconData', 'authorId', 'status'],
          ),
        ),
      },
    );

    final model =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: kDefaultAiModel,
          generationConfig: GenerationConfig(
            responseMimeType: useGoogleSearchTool
                ? 'text/plain'
                : 'application/json',
            responseSchema: learningBiteSchema,
          ),
          tools: useGoogleSearchTool ? [Tool.googleSearch()] : [],
        );

    final userMessageLine = userMessage != null && userMessage.trim().isNotEmpty
        ? '\n• Original-Wunsch des Lernenden: "$userMessage"'
        : '';
    final subjectLine = subject != null && subject.isNotEmpty
        ? '\n• Themenbereich: "$subject"'
        : '';

    final prompt = TextPart('''
Du bist ein Content-Agent einer Bildungs-App. Deine Aufgabe: Erstelle $minBites bis $maxBites aufeinander aufbauende Learning Bites (Lerneinheiten).

Kontext:$userMessageLine$subjectLine
• Anweisung des Lernreise-Agenten: $instruction${additionalText.isNotEmpty ? '\n• Zusätzlicher Inhalt: $additionalText' : ''}

Anforderungen an die Learning Bites:
- Beginne mit dem einfachsten Aspekt des Einstiegs-Konzepts und steigere die Komplexität schrittweise
- Jede Bite deckt ein klar abgegrenztes Unterthema ab
- Der Original-Wunsch des Lernenden (falls angegeben) bestimmt den Ton und den Fokus, die Anweisung des Lernreise-Agenten gibt die genaue inhaltliche Richtung vor
- Nutze Markdown in den content-Einträgen (**fett**, *kursiv*, `code`-Blöcke für Code-Themen)
- Jeder content-Eintrag ist ein eigenständiger, lehrender Absatz oder Stichpunkt

Jeder Learning Bite enthält:
- title: prägnanter Titel des Unterthemas (Deutsch)
- type: "lesson"
- content: 3–6 kurze, lehrreiche Einträge auf Deutsch
- status: "approved"

Gib AUSSCHLIESSLICH das JSON zurück. Kein erklärender Text.
Format: {"learningBites": [{"title": "...", "type": "lesson", "content": ["...", "..."], "status": "approved"}, ...]}
''');

    final List<Part> parts = [prompt];
    parts.addAll(fileParts);
    final response = await model.generateContent([Content.multi(parts)]);
    String bitesJson = response.text ?? '';
    String cleanedJson = bitesJson
        .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
        .trim();
    final Map<String, dynamic> parsedLearningBites = json.decode(cleanedJson);
    List<LearningBite>
    learningBites = (parsedLearningBites['learningBites'] as List)
        .asMap()
        .entries
        .map(
          (entry) => LearningBite.fromMap(
            entry.value,
            'ai_generated_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          ),
        )
        .toList();
    return learningBites;
  }

  /// Generate learning bite tasks from given documents.
  Future<List<tk.Task>> generateLearningBiteTasks({
    String? additionalText = '',
    String? biteTitle,
    String? subject,
    List<Part> fileParts = const [],
    bool useGoogleSearchTool = false,
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return [
        tk.Task(
          id: 'debug_task_1',
          type: TaskType.singleChoice,
          question: 'Was ist die Hauptstadt von Frankreich?',
          correctAnswer: 'Paris',
          answers: ['Paris', 'Berlin', 'Madrid', 'Rom'],
        ),
        tk.Task(
          id: 'debug_task_2',
          type: TaskType.freeTextFieldCloze,
          question: 'Die Erde dreht sich um die ____.',
          correctAnswer: 'Sonne',
        ),
      ];
    }

    final taskJsonSchema = Schema.object(
      properties: {
        'tasks': Schema.array(
          items: Schema.object(
            properties: {
              'type': Schema.enumString(
                enumValues: [
                  'singleChoice',
                  'singleChoiceCloze',
                  'freeTextFieldCloze',
                  'indexCard',
                ],
              ),
              'question': Schema.string(),
              'correctAnswer': Schema.string(),
              'answers': Schema.array(items: Schema.string()),
            },
            optionalProperties: ['answers'],
          ),
        ),
      },
    );

    final model =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: kDefaultAiModel,
          generationConfig: GenerationConfig(
            responseMimeType: useGoogleSearchTool
                ? 'text/plain'
                : 'application/json',
            responseSchema: taskJsonSchema,
          ),
          tools: useGoogleSearchTool ? [Tool.googleSearch()] : [],
        );
    final biteTitleLine = biteTitle != null && biteTitle.isNotEmpty
        ? '\nLerneinheit: "$biteTitle"'
        : '';
    final subjectLine2 = subject != null && subject.isNotEmpty
        ? '\nThemenbereich: "$subject"'
        : '';
    final prompt = TextPart('''
Du bist ein Aufgaben-Generator für eine Bildungs-App.$subjectLine2$biteTitleLine

Erstelle 3–5 abwechslungsreiche Übungsaufgaben zum unten stehenden Lerninhalt.

Aufgabentypen und wann verwenden:
- singleChoice       → Verständnisfragen mit mindestens 2 Antwortoptionen (1 korrekt)
- singleChoiceCloze  → Lückentext; der Lernende wählt die richtige Ergänzung aus mindestens 2 Optionen
- freeTextFieldCloze → Lückentext ohne Optionen; der Lernende tippt fehlende Wort/e bzw. Phrase/n ein
- indexCard          → Lernkarte: Vorderseite = Begriff/Konzept, Rückseite = prägnante Erklärung

Regeln:
- Variiere die Aufgabentypen (nicht nur singleChoice)
- Lückentexte (cloze) enden mit einem Satzzeichen und markieren die Lücken mit {}
- Bei freeTextFieldCloze: correctAnswer = die fehlenden Wörter/Phrasen in der Reihenfolge ihres Auftretens, getrennt durch '{}', z. B. "Wort1{}Wort2"
- Bei singleChoice/singleChoiceCloze: mindestens 2 Einträge in "answers", davon 1 korrekt
- KRITISCH: Bei singleChoice und singleChoiceCloze muss "correctAnswer" exakt (Zeichen für Zeichen, gleiche Groß-/Kleinschreibung) mit einem der Einträge in "answers" übereinstimmen
- Fragen und Antworten auf Deutsch, korrekte Groß-/Kleinschreibung
- In "question" ist Markdown erlaubt (z. B. **fett**, *kursiv*, `Code`)
- In "correctAnswer" und "answers" NUR Klartext (plain text): KEIN Markdown, KEINE HTML-Tags, KEINE Farbtags
- KEINE Antwortlabels oder Buchstaben-Optionen wie "A", "B", "C", "D" als Antworten
- KEINE Formulierungen wie "A) ...", "B) ...", "C) ...", "D) ..." in Fragen oder Antworten
- Jede Option in "answers" muss der tatsächliche inhaltliche Antworttext sein (z. B. "Paris", "Berlin"), nicht nur ein Buchstabe oder Label
- Vermeide die Frageform „Welche Aussage ist korrekt? A/B/C/D“ vollständig

Gib AUSSCHLIESSLICH das JSON zurück. Kein erklärender Text.
Format: {"tasks": [{"type": "singleChoice|singleChoiceCloze|freeTextFieldCloze|indexCard", "question": "...", "correctAnswer": "...", "answers": ["...", "..."]}, ...]}
Beispiel singleChoice: {"type": "singleChoice", "question": "Was ist 2+2?", "correctAnswer": "4", "answers": ["3", "4", "5", "6"]}
→ correctAnswer "4" ist identisch mit dem Eintrag "4" in answers.
Lerninhalt:
''');

    final List<Part> parts = [prompt];
    parts.addAll(fileParts);
    if (additionalText != null && additionalText.isNotEmpty) {
      parts.add(TextPart("Zusätzlicher Textinhalt: $additionalText"));
    }
    final response = await model.generateContent([Content.multi(parts)]);
    String tasksJson = response.text ?? '';
    String cleanedTasksJson = tasksJson
        .replaceAll(RegExp(r'```[a-zA-Z]*'), '')
        .trim();
    final Map<String, dynamic> parsedTasks = json.decode(cleanedTasksJson);
    List<tk.Task> tasks = (parsedTasks['tasks'] as List)
        .asMap()
        .entries
        .map(
          (entry) => tk.Task.fromMap(
            entry.value,
            'ai_generated_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          ),
        )
        .toList();
    return tasks;
  }

  /// Generates a short AI Tech knowledge check plan for a selected learning material.
  Future<List<AiTechKnowledgeCheckPrompt>> generateAiTechKnowledgeCheckPrompts({
    String? subject,
    String? additionalText = '',
    List<Part> fileParts = const [],
    bool useGoogleSearchTool = false,
    int maxQuestions = 3,
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return [
        const AiTechKnowledgeCheckPrompt(
          prompt:
              'Erkläre das Kernkonzept dieses Materials mit deinen eigenen Worten.',
          followUp:
              'Nenne ein konkretes Beispiel oder einen Teil des Materials, der die Idee verdeutlicht.',
          assessment:
              'Du verstehst das Hauptprinzip bereits gut. Fokus auf die Erklärung und ein praktisches Beispiel.',
        ),
        const AiTechKnowledgeCheckPrompt(
          prompt:
              'Was ist der wichtigste Unterschied zwischen den zentralen Begriffen in diesem Abschnitt?',
          followUp:
              'Vergleiche sie mit einem kurzen Beispiel aus dem Lerninhalt.',
          assessment:
              'Die zentrale Unterscheidung ist klar. Wiederhole sie noch einmal mit einem eigenen Beispiel.',
        ),
      ];
    }

    final schema = Schema.object(
      properties: {
        'questions': Schema.array(
          items: Schema.object(
            properties: {
              'prompt': Schema.string(),
              'followUp': Schema.string(),
              'assessment': Schema.string(),
            },
            optionalProperties: ['followUp', 'assessment'],
          ),
        ),
      },
    );

    final model =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: kDefaultAiModel,
          generationConfig: GenerationConfig(
            responseMimeType: useGoogleSearchTool
                ? 'text/plain'
                : 'application/json',
            responseSchema: schema,
          ),
          tools: useGoogleSearchTool ? [Tool.googleSearch()] : [],
        );

    final subjectLine = subject != null && subject.isNotEmpty
        ? '\nThemenbereich: "$subject"'
        : '';

    final prompt = TextPart('''
Du bist eine unterstützende Lernbegleitung für eine Bildungs-App.
Erstelle genau $maxQuestions kurze Prüfungsfragen, die eine verständliche Erklärung, eine begründete Antwort und eine gezielte Rückfrage fördern.$subjectLine

Ziel:
- Jede Frage soll ein zentrales Konzept aus dem Lernmaterial prüfen.
- Die Antwort soll in eigenen Worten erklärt werden.
- Wenn der Lernende die Frage nicht gut beantwortet, hilft die followUp-Frage, das Verständnis präzise zu vertiefen.
- Die assessment soll eine knappe Gesamtbewertung mit einem klaren nächsten Schritt enthalten.

Achte auf:
- Nur Deutsch.
- Wenn nötig, sprich den Lernenden in der Du-Form an.
- Keine generischen Wörter wie „Frage 1“ im Text.
- Konkrete, auf das Material bezogene Fragen.
- Antwortformat als JSON: {"questions": [{"prompt": "...", "followUp": "...", "assessment": "..."}, ...]}

Lerninhalt:
''');

    final List<Part> parts = [prompt];
    parts.addAll(fileParts);
    if (additionalText != null && additionalText.trim().isNotEmpty) {
      parts.add(TextPart("Zusätzlicher Textinhalt: $additionalText"));
    }

    final response = await model.generateContent([Content.multi(parts)]);
    final content = response.text ?? '{}';
    final cleaned = content.replaceAll(RegExp(r'```[a-zA-Z]*'), '').trim();
    final parsed = json.decode(cleaned) as Map<String, dynamic>;
    final questions = (parsed['questions'] as List?) ?? const [];
    return questions
        .map(
          (entry) => AiTechKnowledgeCheckPrompt.fromMap(
            Map<String, dynamic>.from(entry),
          ),
        )
        .toList();
  }

  /// Generates spoken audio for an AI Tech knowledge check question using Firebase AI Logic.
  Stream<Uint8List> generateAiTechKnowledgeCheckSpeech(String text) async* {
    if (kDebugMode && !kUseRealAiInDebug) {
      return;
    }

    final model =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: 'gemini-3.1-flash-tts-preview',
          generationConfig: GenerationConfig(
            responseModalities: [ResponseModalities.audio],
            speechConfig: SpeechConfig(
              voiceName: 'Kore',
              languageCode: 'de-DE',
            ),
          ),
        );
    final responseStream = model.generateContentStream([
      Content.text('''
[Audio Profile: Eine freundliche, ruhige und professionelle Lernbegleiterin]
[Scene: Ein entspannter AI Tech Wissenscheck in einer ruhigen Lernumgebung]
[Director's Notes: Sprich klar, natürlich und ermutigend. Verwende ein moderates Tempo, eine warme Tonlage und eine deutliche deutsche Aussprache. Stelle die Frage interessiert und ohne Druck.]
[Sample Context: Die Lernbegleiterin stellt dem Lernenden die nächste Frage und gibt ihm Zeit, in eigenen Worten zu antworten.]
$text
'''),
    ]);
    await for (final response in responseStream) {
      for (final candidate in response.candidates) {
        for (final part in candidate.content.parts) {
          if (part is InlineDataPart && part.mimeType.startsWith('audio/')) {
            yield part.bytes;
          }
        }
      }
    }
  }

  /// Transcribes and evaluates a recorded answer, then creates an adaptive
  /// follow-up question when the learner's explanation has a clear gap.
  Future<AiTechKnowledgeCheckAnswerFeedback> analyzeAiTechKnowledgeCheckAudio({
    required String question,
    required String subject,
    required Uint8List audioData,
    required String mimeType,
    bool isFollowUp = false,
    String? additionalText,
    List<Part> fileParts = const [],
  }) async {
    if (kDebugMode && !kUseRealAiInDebug) {
      return const AiTechKnowledgeCheckAnswerFeedback(
        transcript: 'Debug-Antwort',
        feedback:
            'Die Kernaussage ist teilweise erklärt. Ergänze ein konkretes Beispiel.',
        isCorrect: false,
        correctAnswer:
            'Eine vollständige Antwort erklärt die Kernaussage und belegt sie '
            'mit einem passenden Beispiel aus dem Material.',
        nextAction:
            'Übe die Erklärung mit einem eigenen Beispiel aus dem Material.',
        needsFollowUp: true,
        followUpQuestion:
            'Welches konkrete Beispiel aus dem Material belegt deine Erklärung?',
      );
    }

    final transcriptionModel =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: kDefaultAiModel,
          generationConfig: GenerationConfig(
            temperature: 0,
            responseMimeType: 'text/plain',
          ),
        );
    final transcriptionResponse = await transcriptionModel
        .generateContent([
          Content.multi([
            TextPart(
              'Transkribiere die folgende Audioaufnahme wortgetreu in der '
              'gesprochenen Sprache. Gib ausschließlich die erkannten Wörter '
              'aus. Beantworte keine Frage, fasse nichts zusammen, korrigiere '
              'keine Grammatik und ergänze keine vermuteten Wörter. Wenn ein '
              'Wort nicht verständlich ist, markiere es als [unverständlich].',
            ),
            InlineDataPart(mimeType, audioData),
          ]),
        ])
        .timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw TimeoutException(
            'Die Transkription hat länger als 45 Sekunden gedauert. '
            'Bitte prüfe deine Verbindung und versuche es erneut.',
          ),
        );
    final transcript = transcriptionResponse.text?.trim() ?? '';
    if (transcript.isEmpty) {
      throw StateError('Die gesprochene Antwort konnte nicht erkannt werden.');
    }

    final schema = Schema.object(
      properties: {
        'feedback': Schema.string(),
        'isCorrect': Schema.boolean(),
        'correctAnswer': Schema.string(),
        'nextAction': Schema.string(),
        'needsFollowUp': Schema.boolean(),
        'followUpQuestion': Schema.string(),
      },
    );
    final model =
        FirebaseAI.googleAI(
          useLimitedUseAppCheckTokens: kUseLimitedUseAppCheckTokens,
        ).generativeModel(
          model: kDefaultAiModel,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: schema,
          ),
        );
    final prompt = TextPart('''
Du bist eine sorgfältige, unterstützende Lernbegleitung.
Thema: $subject
Aktuelle Frage: $question
${isFollowUp ? 'Dies ist die einmalige Rückfrage zu einer vorherigen Frage. Bewerte, ob die Antwort die offene Lücke schließt. Stelle keine weitere Rückfrage.' : ''}
${additionalText?.trim().isNotEmpty == true ? 'Lernmaterial:\\n$additionalText' : ''}

Bewerte die folgende Transkription, ohne sie umzuschreiben oder zu ergänzen:
$transcript

Bewerte, ob die Antwort die Frage inhaltlich korrekt und ausreichend erklärt.
Setze isCorrect nur dann auf true, wenn die Antwort korrekt und ausreichend ist.
Gib kurzes, konkretes Feedback. Wenn die Antwort korrekt ist, erkläre im
Feedback kurz, warum sie richtig ist. Erstelle immer eine kurze, sachlich
richtige Musterantwort in correctAnswer. Wenn ein wichtiges Konzept fehlt oder
unklar ist und dies keine Rückfrage ist, setze needsFollowUp auf true und stelle
genau eine gezielte, kurze Rückfrage, die diese Lücke prüft. Andernfalls setze
needsFollowUp auf false und followUpQuestion auf einen leeren String. Bei einer
Rückfrage darf keine weitere Rückfrage gestellt werden. Gib außerdem einen
passenden konkreten nächsten Lernschritt in nextAction an. Erfinde keine
Anforderungen, die nicht aus der Frage oder dem Lernmaterial hervorgehen. Die
Rückmeldung ist beratend.

Gib ausschließlich JSON zurück mit den Feldern feedback, nextAction,
needsFollowUp und followUpQuestion.
''');
    final response = await model
        .generateContent([
          Content.multi([prompt, ...fileParts]),
        ])
        .timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw TimeoutException(
            'Die Auswertung hat länger als 45 Sekunden gedauert. '
            'Bitte prüfe deine Verbindung und versuche es erneut.',
          ),
        );
    final decoded = json.decode(response.text ?? '') as Map<String, dynamic>;
    final feedback = AiTechKnowledgeCheckAnswerFeedback.fromMap({
      ...decoded,
      'transcript': transcript,
    });
    if (feedback.correctAnswer.trim().isEmpty) {
      throw const FormatException(
        'Die Auswertung enthielt keine kurze Musterantwort.',
      );
    }
    return feedback;
  }
}
