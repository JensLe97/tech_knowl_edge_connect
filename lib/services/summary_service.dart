import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SummaryService {
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
    final model =
        FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');
    final prompt = TextPart(
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
}
