import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/models/task.dart' as tk;

class AiTechService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  /// Summarizes multiple documents by streaming their combined summary.
  Stream<GenerateContentResponse> summarizeMultipleData({
    required List<String> urls,
    required List<String> mimeTypes,
  }) async* {
    if (urls.length != mimeTypes.length) {
      throw ArgumentError(
          'Die Anzahl der URLs muss der Anzahl der MIME-Typen entsprechen.');
    }
    final model = FirebaseAI.googleAI(
      appCheck: FirebaseAppCheck.instance,
    ).generativeModel(model: 'gemini-2.5-flash');
    const prompt = TextPart(
        "Fasse die wichtigsten Punkte dieser Dateien zusammen. "
        "Erstelle eine übersichtliche Zusammenfassung in deutscher Sprache. "
        "Nutze Aufzählungen, wo es sinnvoll ist.");
    // Download all files and create their DataParts
    final List<InlineDataPart> docParts = [];
    for (int i = 0; i < urls.length; i++) {
      final reference = _firebaseStorage.refFromURL(urls[i]);
      final doc = await reference.getData();
      docParts.add(InlineDataPart(mimeTypes[i], doc!));
    }
    // Combine prompt and all document parts
    final content = [prompt, ...docParts];
    final response = model.generateContentStream([Content.multi(content)]);
    yield* response;
  }

  /// Generate a learning bite from given documents.
  Future<List<tk.Task>> generateLearningBite({
    required List<String> urls,
    required List<String> mimeTypes,
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
        "Erstelle eine Liste von Tasks aus den gegebenen Dokumenten. "
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
        "Nutze verschiedene Aufgabentypen und decke unterschiedliche Aspekte der Dokumente ab."
        "Die Dokumente sind in deutscher Sprache."
        "Die Aufgaben vom Typ singleChoiceCloze oder freeTextFieldCloze"
        "müssen mit einem Fragetext beginnen und enden, z.B. einem Punkt am Ende."
        "Nutze leere geschweifte Klammern {} in einer Frage, um eine Lücke zu kennzeichnen."
        "Wenn du dir unsicher bist, erstelle eine einfachere Aufgabe."
        "Erstelle mindestens 2 Aufgaben."
        "Wenn die Dokumente keinen Inhalt haben, gib eine leere Aufgabenliste zurück."
        "Hier sind die Dokumente:");
    // Download all files and create their DataParts
    final List<InlineDataPart> docParts = [];
    for (int i = 0; i < urls.length; i++) {
      final reference = _firebaseStorage.refFromURL(urls[i]);
      final doc = await reference.getData();
      docParts.add(InlineDataPart(mimeTypes[i], doc!));
    }
    // Combine prompt and all document parts
    final content = [prompt, ...docParts];
    final response = await model.generateContent([Content.multi(content)]);
    String tasksJson = response.text ?? '';
    final Map<String, dynamic> parsedTasks = json.decode(tasksJson);
    List<tk.Task> tasks = (parsedTasks['tasks'] as List)
        .map((val) => tk.Task.fromJson(val))
        .toList();
    return tasks;
  }
}
