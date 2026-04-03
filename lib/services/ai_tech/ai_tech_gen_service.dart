import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
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
        properties: {
          'parts': Schema.array(items: Schema.string()),
        },
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
          "Antworte im JSON-Format: {'parts': ['Abschnitt 1', 'Abschnitt 2', ...]}");
    }

    buffer.write(
        "Erstelle eine übersichtliche Zusammenfassung in deutscher Sprache, "
        "sodass sie zum Lernen und schnellen Verstehen der Inhalte geeignet ist. "
        "Die Zusammenfassung soll im Markdown-Format sein, damit sie später gut dargestellt werden können. "
        "$_markdownStyling"
        "$_generalInstructions");

    final model = FirebaseAI.googleAI(
      appCheck: FirebaseAppCheck.instance,
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
              'iconData': Schema.object(properties: {
                'codePoint': Schema.integer(),
                'fontFamily': Schema.string(),
                'fontPackage': Schema.string(),
              }, optionalProperties: [
                'fontFamily',
                'fontPackage'
              ]),
              'authorId': Schema.string(),
              'status': Schema.string(),
            },
            optionalProperties: ['completed', 'iconData', 'authorId', 'status'],
          ),
        ),
      },
    );

    final model = FirebaseAI.googleAI(
      appCheck: FirebaseAppCheck.instance,
    ).generativeModel(
        model: kDefaultAiModel,
        generationConfig: GenerationConfig(
          responseMimeType:
              useGoogleSearchTool ? 'text/plain' : 'application/json',
          responseSchema: learningBiteSchema,
        ),
        tools: useGoogleSearchTool ? [Tool.googleSearch()] : []);

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
    String cleanedJson =
        bitesJson.replaceAll(RegExp(r'```[a-zA-Z]*'), '').trim();
    final Map<String, dynamic> parsedLearningBites = json.decode(cleanedJson);
    List<LearningBite> learningBites = (parsedLearningBites['learningBites']
            as List)
        .asMap()
        .entries
        .map((entry) => LearningBite.fromMap(entry.value,
            'ai_generated_${DateTime.now().millisecondsSinceEpoch}_${entry.key}'))
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
              'type': Schema.enumString(enumValues: [
                'singleChoice',
                'singleChoiceCloze',
                'freeTextFieldCloze',
                'indexCard',
              ]),
              'question': Schema.string(),
              'correctAnswer': Schema.string(),
              'answers': Schema.array(
                items: Schema.string(),
              ),
            },
            optionalProperties: ['answers'],
          ),
        ),
      },
    );

    final model = FirebaseAI.googleAI(
      appCheck: FirebaseAppCheck.instance,
    ).generativeModel(
        model: kDefaultAiModel,
        generationConfig: GenerationConfig(
          responseMimeType:
              useGoogleSearchTool ? 'text/plain' : 'application/json',
          responseSchema: taskJsonSchema,
        ),
        tools: useGoogleSearchTool ? [Tool.googleSearch()] : []);
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
    String cleanedTasksJson =
        tasksJson.replaceAll(RegExp(r'```[a-zA-Z]*'), '').trim();
    final Map<String, dynamic> parsedTasks = json.decode(cleanedTasksJson);
    List<tk.Task> tasks = (parsedTasks['tasks'] as List)
        .asMap()
        .entries
        .map((entry) => tk.Task.fromMap(entry.value,
            'ai_generated_${DateTime.now().millisecondsSinceEpoch}_${entry.key}'))
        .toList();
    return tasks;
  }
}
