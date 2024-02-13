import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "TBD": [
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
};

Map<String, List<Task>> tasks = {
  "TBD": [
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
};

List<LearningBite> volationLearningBites = [
  LearningBite(
      name: "TBD",
      type: LearningBiteType.lesson,
      data: data["TBD"]!,
      iconData: FontAwesomeIcons.hammer,
      tasks: tasks["TBD"]!),
];
