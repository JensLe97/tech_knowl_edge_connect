import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Allgemeine Merkmale": [
    Column(
      children: [
        const Text("""
Reptilien haben folgende Eigenschaften:\n
  1. Wechselwarm
  2. Trockene, schuppige Haut
  3. Atmung über Lungen (nicht über Haut)
  4. 5 Zehen an Vorder- und Hinterbeinen
  5. Keine Metamorphose
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Reptilien haben einen doppelten Blutkreislauf:\n
  Dreikammeriges Herz
        """),
        SizedBox(
          height: 300,
          child:
              Image.asset('images/learning_bites/biology/reptiles_cycle.png'),
        ),
        const Text("""
Krokodile: vierkammerig, vollständig getrennte Kammern\n
        """),
        SizedBox(
          height: 300,
          child:
              Image.asset('images/learning_bites/biology/reptiles_cycle.png'),
        ),
      ],
    ),
  ],
  "Fortpflanzung": [],
};

Map<String, List<Task>> tasks = {
  "Allgemeine Merkmale": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Schildkröten ernähren sich {}.",
        correctAnswer: "omnivor",
        answers: ["carnivor", "herbivor", "omnivor", "insektivor"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Schlangen und Krokodile ernähren sich {}.",
        correctAnswer: "carnivor",
        answers: ["carnivor", "herbivor", "omnivor", "insektivor"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Echsen ernähren sich {}.",
        correctAnswer: "insektivor",
        answers: ["carnivor", "herbivor", "omnivor", "insektivor"]),
  ],
  "Fortpflanzung": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Die meisten Amphibien sind {}.",
        correctAnswer: "ovipar",
        answers: ["ovipar", "ovulipar", "ovovipar"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Chamäleons, europäische Kreuzotter und manche Schlangen pflanzen sich {} vor.",
        correctAnswer: "ovovipar",
        answers: ["ovipar", "ovulipar", "ovovipar"]),
  ],
};

List<LearningBite> reptilesLearningBites = [
  LearningBite(
      name: "Allgemeine Merkmale",
      type: LearningBiteType.lesson,
      data: data["Allgemeine Merkmale"]!,
      iconData: FontAwesomeIcons.dragon,
      tasks: tasks["Allgemeine Merkmale"]!),
  LearningBite(
      name: "Fortpflanzung",
      type: LearningBiteType.lesson,
      data: data["Fortpflanzung"]!,
      iconData: FontAwesomeIcons.venusMars,
      tasks: tasks["Fortpflanzung"]!),
];
