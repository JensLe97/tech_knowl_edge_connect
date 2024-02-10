import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';

Map<String, List<Widget>> data = {
  "Erwartungsarten": [
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
  "Fähigkeitsselbstkonzept": [
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
};

Map<String, List<Task>> tasks = {
  "Erwartungsarten": [
    Task(
        question: "Ist die Zahl 5 eine natürliche Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein", "Vielleicht"]),
    Task(
        question: "Ist die Zahl -2 eine natürliche Zahl?",
        correctAnswer: "Nein",
        answers: ["Ja", "Nein"]),
  ],
  "Fähigkeitsselbstkonzept": [
    Task(
        question: "Ist die Zahl 5 eine ganze Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
    Task(
        question: "Ist die Zahl -2 eine ganze Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
  ],
};

List<LearningBite> expectationLearningBites = [
  LearningBite(
      name: "Erwartungsarten",
      type: LearningBiteType.lesson,
      data: data["Erwartungsarten"]!,
      iconData: FontAwesomeIcons.diagramProject,
      tasks: tasks["Erwartungsarten"]!),
  LearningBite(
      name: "Fähigkeitsselbstkonzept",
      type: LearningBiteType.lesson,
      data: data["Fähigkeitsselbstkonzept"]!,
      iconData: FontAwesomeIcons.boxOpen,
      tasks: tasks["Fähigkeitsselbstkonzept"]!),
];
