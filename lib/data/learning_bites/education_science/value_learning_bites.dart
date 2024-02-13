import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Handungsarten": [
    Column(
      children: [
        const Text("Zahlen von 1 bis unendlich. Also 1, 2, 3, 4, ..."),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Werte einer Handlung": [
    Column(
      children: [
        const Text(
            "Natürliche Zahlen und negative ganzzahlige (..., -2, -1, 0, 1, 2, ...)."),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Ziele": [
    Column(
      children: [
        const Text(
            "Es gibt 3 grundlegende Rechengesetze. Das Kommutativgesetz, das Assoziativgesetz und das Distributivgesetz."),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
};

Map<String, List<Task>> tasks = {
  "Handungsarten": [
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl 5 eine natürliche Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein", "Vielleicht"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl -2 eine natürliche Zahl?",
        correctAnswer: "Nein",
        answers: ["Ja", "Nein"]),
  ],
  "Werte einer Handlung": [
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl 5 eine ganze Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl -2 eine ganze Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
  ],
  "Ziele": [
    Task(
        type: TaskType.singleChoice,
        question: "Wie lautet das Kommutativgesetz?",
        correctAnswer: "a + b = b + a",
        answers: ["a + b = b + a", "a - b = b - a"]),
    Task(
        type: TaskType.singleChoice,
        question: "Welches Gesetz lautet a * (b + c) = a * b + a * c?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz wird hier angewendet: 9 + 2 + 10 = 9 + 10 + 2?",
        correctAnswer: "Assoziativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question: "Welches Gesetz behandelt das 'Vertauschen' von zwei Zahlen?",
        correctAnswer: "Kommutativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz wird hier angewendet: 9 * (2 + 10) = 9 * 2 + 9 * 10?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz behandelt das 'Verbinden/Verknüpfen' in beliebiger Reihenfolge?",
        correctAnswer: "Assoziativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz behandelt das 'Aufteilen/Verteilen' von einer Zahl auf zwei andere Zahlen?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question: "Das Assoziativgesetz lautet a * b = b * a",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bei welchem Gesetz lässt sich das Plus mit einem Minus ersetzen?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
  ],
};

List<LearningBite> valueLearningBites = [
  LearningBite(
      name: "Handungsarten",
      type: LearningBiteType.lesson,
      data: data["Handungsarten"]!,
      iconData: FontAwesomeIcons.chessBoard,
      tasks: tasks["Handungsarten"]!),
  LearningBite(
      name: "Werte einer Handlung",
      type: LearningBiteType.lesson,
      data: data["Werte einer Handlung"]!,
      iconData: FontAwesomeIcons.award,
      tasks: tasks["Werte einer Handlung"]!),
  LearningBite(
      name: "Ziele",
      type: LearningBiteType.lesson,
      data: data["Ziele"]!,
      iconData: FontAwesomeIcons.rocket,
      tasks: tasks["Ziele"]!),
];
