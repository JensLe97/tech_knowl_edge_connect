import 'package:tech_knowl_edge_connect/models/task_type.dart';

class Task {
  final String id;
  final TaskType type;
  final String question;
  final String correctAnswer;
  final List<String> answers;

  Task({
    required this.id,
    required this.type,
    required this.question,
    required this.correctAnswer,
    this.answers = const [],
  });

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      type: TaskType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TaskType.singleChoice,
      ),
      question: (data['question'] ?? '').replaceAll(r'\n', '\n'),
      correctAnswer: (data['correctAnswer'] ?? '').replaceAll(r'\n', '\n'),
      answers: List<String>.from(data['answers'] ?? [])
          .map((e) => e.replaceAll(r'\n', '\n'))
          .toList(),
    );
  }
}
