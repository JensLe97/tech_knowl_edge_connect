import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/models/task.dart' as tk;

class AiTechService {
  static const String _markdownStyling =
      "Verwende dabei auch Aufzählungen, Nummerierungen, Fettdruck, Kursivschrift, horizontale Trennlinien, Codeblöcke, Tabellen, "
      "Emojis, Zitate um wichtige Stellen hervorzuheben oder andere Markdown-Elemente, wenn es sinnvoll ist. "
      "Verwende wenn es sinnvoll ist gelegentlich verschiedene Farben um Wörter hervorzuheben, z.B. <red>roter Text</red> oder <green>grüner Text</green>."
      "Folgende Farben stehen zur Verfügung: red, green, blue, yellow, orange, purple, grey, gray."
      "Setze Farben nur selten ein und verwende Fettdruck und andere Hervorhebungen außerhalb der Farb-Tags.";

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Summarizes multiple documents by streaming their combined summary.
  Stream<GenerateContentResponse> summarizeMultipleData({
    required List<String> urls,
    required List<String> mimeTypes,
    String? additionalText,
    bool splitIntoParts = false,
  }) async* {
    if (urls.length != mimeTypes.length) {
      throw ArgumentError(
          'Die Anzahl der URLs muss der Anzahl der MIME-Typen entsprechen.');
    }

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
        "Die Dokumente sind in deutscher Sprache. "
        "Hier sind die Dokumente und Texte: ");

    final model = FirebaseAI.googleAI(
      appCheck: FirebaseAppCheck.instance,
    ).generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: generationConfig,
    );
    final prompt = TextPart(buffer.toString());

    // Download all files and create their DataParts
    final List<Part> parts = [prompt];
    for (int i = 0; i < urls.length; i++) {
      final reference = _firebaseStorage.refFromURL(urls[i]);
      final doc = await reference.getData();
      parts.add(InlineDataPart(mimeTypes[i], doc!));
    }
    if (additionalText != null && additionalText.isNotEmpty) {
      parts.add(TextPart("Zusätzlicher Textinhalt: $additionalText"));
    }
    final response = model.generateContentStream([Content.multi(parts)]);
    yield* response;
  }

  /// Generate a learning bite from given documents.
  Future<List<tk.Task>> generateLearningBite({
    required List<String> urls,
    required List<String> mimeTypes,
    String? additionalText,
  }) async {
    if (urls.length != mimeTypes.length) {
      throw ArgumentError(
          'Die Anzahl der URLs muss der Anzahl der MIME-Typen entsprechen.');
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
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: taskJsonSchema));
    const prompt = TextPart(
        "Erstelle eine Liste von Tasks aus den gegebenen Dokumenten und Texten. "
        "Die Aufgaben sollen verschiedene Formate haben, z.B. Multiple oder Single Choice, Lückentexte oder Karteikarten. "
        "Die Fragen und Antworten sollen auf Deutsch sein. "
        "Achte auf Groß- und Kleinschreibung bei den Antworten und Fragen."
        "Gib die Aufgaben in folgendem JSON-Format zurück: "
        '{"tasks": ['
        '{"type": "singleChoice" | "singleChoiceCloze" | "freeTextFieldCloze" | "indexCard", '
        '"question": "Frage", '
        '"correctAnswer": "Korrekte Antwort", '
        '"answers": ["Antwort 1", "Antwort 2", "..."] // Nur für Multiple oder Single Choice'
        '}, '
        '...'
        ']}'
        "Achte darauf, dass das JSON korrekt formatiert ist und keine zusätzlichen Erklärungen oder Text enthält."
        "Die Fragen sollen im Markdown-Format sein, damit sie später gut dargestellt werden können."
        "Eine neue Zeile in einer Frage soll mit '\\n\\n' angegeben werden. "
        "$_markdownStyling"
        "Nutze verschiedene Aufgabentypen und decke unterschiedliche Aspekte der Dokumente ab."
        "Die Dokumente sind in deutscher Sprache."
        "Die Aufgaben vom Typ singleChoiceCloze oder freeTextFieldCloze"
        "müssen mit einem Fragetext beginnen und enden, z.B. einem Punkt am Ende."
        "Nutze leere geschweifte Klammern {} in einer Frage, um eine Lücke zu kennzeichnen."
        "Wenn du dir unsicher bist, erstelle eine einfachere Aufgabe."
        "Erstelle mindestens 2 Aufgaben."
        "Wenn die Dokumente keinen Inhalt haben, gib eine leere Aufgabenliste zurück."
        "Hier sind die Dokumente und Texte:");
    // Download all files and create their DataParts
    final List<Part> parts = [prompt];
    for (int i = 0; i < urls.length; i++) {
      final reference = _firebaseStorage.refFromURL(urls[i]);
      final doc = await reference.getData();
      parts.add(InlineDataPart(mimeTypes[i], doc!));
    }
    if (additionalText != null && additionalText.isNotEmpty) {
      parts.add(TextPart("Zusätzlicher Textinhalt: $additionalText"));
    }
    final response = await model.generateContent([Content.multi(parts)]);
    String tasksJson = response.text ?? '';
    final Map<String, dynamic> parsedTasks = json.decode(tasksJson);
    List<tk.Task> tasks = (parsedTasks['tasks'] as List)
        .asMap()
        .entries
        .map((entry) => tk.Task.fromMap(entry.value,
            'ai_generated_${DateTime.now().millisecondsSinceEpoch}_${entry.key}'))
        .toList();
    return tasks;
  }
}
