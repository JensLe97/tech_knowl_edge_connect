import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Erwartungsarten": [
    Column(
      children: [
        const Text("""
Entscheidend für die Lern- un Leistungsmotivation ist die Erfolgserwartung.\n
Man spricht von einer hohen Erfolgserwartung, wenn SuS überzeugt sind, bei einer Arbeit eine gute Leistung zu erzielen.
        """),
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
        const Text("""
Das Fähigkeitsselbstkonzept beschreibt kognitive Repräsentationen eigener Fähigkeiten und Begabungen.\n
        """),
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
        type: TaskType.singleChoiceCloze,
        question:
            "Die Erfolgserwartung bezeichnet die {} Einschätzung, mit welcher Wahrscheinlichkeit Erfolg eintritt.",
        correctAnswer: "subjektive",
        answers: ["subjektive", "objektive"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die Erwartungen bilden sich in der prädezisionalen Phase aus.",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Die Handlungs-Ergebnis-Erwartung bezeichnet die angenommene Wahrscheinlichkeit, mit der ein Ergebnis durch {} herbeigeführt wird.",
        correctAnswer: "eigenes Handeln",
        answers: ["die Situation", "eigenes Handeln"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Die Situations-Ergebniserwartung bezeichnet die angenommene Wahrscheinlichkeit, mit der ein Ergebnis durch {} herbeigeführt wird.",
        correctAnswer: "die Situation",
        answers: ["die Situation", "eigenes Handeln"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Ergebnis-Folgen-Erwartung bezeichnet die angenommene Wahrscheinlichkeit, mit der ein Ergebnis zu den gewünschten {} führt.",
        correctAnswer: "Folgen",
        answers: []),
  ],
  "Fähigkeitsselbstkonzept": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Wirkung des Fähigkeitsselbstkonzeptes auf die aktuelle Motivation ist sehr groß. Es beeinflusst die schulischen Leistungen, was als {} bezeichnet wird.",
        correctAnswer: "self enhancement",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Es wurde ein positiver Einfluss von {}erwartungen auf die Motivation von SuS erkannt.",
        correctAnswer: "Lehrkräfte",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Die Erwartungskomponente spiegelt die Einschätzung der {} eines erwünschten Zustandes wider.",
        correctAnswer: "Realisierbarkeit",
        answers: ["Realisierbarkeit", "Nützlichkeit"]),
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
