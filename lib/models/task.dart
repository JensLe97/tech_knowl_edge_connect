import 'package:tech_knowl_edge_connect/models/task_type.dart';

class Task {
  final TaskType type;
  // Questions with TaskType singleChoiceCloze or freeTextFieldCloze
  // must start and end with a question text, e.g., a dot at the end.
  final String question;
  final String correctAnswer;
  final List<String> answers;

  Task(
      {required this.type,
      required this.question,
      required this.correctAnswer,
      this.answers = const []});
}
