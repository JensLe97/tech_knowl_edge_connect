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
Allgemeine Merkmale von Amphibien sind:\n
  1. Wechselwarm
  2. Feuchte Haut mit Schleim- und Giftdrüsen
  3. Atmung (adult) über Lungen, Haut und Mundhöhle
  4. 4 Zehen an Vorder- und 5 an Hinterbeine
  5. Durchlaufen Metamorphose (Larve bis Tier)
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
Im Gegensatz zu Fischen haben Amphibien einen doppelten Blutkreislauf\n
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/amphibians_cycle.png'),
        ),
      ],
    ),
  ],
  "Fortpflanzung": [
    Column(
      children: [
        const Text("""
Als Larve atmen sie über Kiemen und ausgewachsen über Lunge\n
        """),
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
  "Fortpflanzung": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Frösche pflanzen sich {} fort.",
        correctAnswer: "ovulipar",
        answers: ["ovulipar", "ovipar", "vivipar"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Die Entwicklung von der Kaulquappe zum Frosch nennt man {}.",
        correctAnswer: "Metamorphose",
        answers: []),
  ],
};

List<LearningBite> amphibiansLearningBites = [
  LearningBite(
    name: "Allgemeine Merkmale",
    type: LearningBiteType.text,
    data: data["Allgemeine Merkmale"]!,
    iconData: FontAwesomeIcons.frog,
  ),
  LearningBite(
      name: "Fortpflanzung",
      type: LearningBiteType.lesson,
      data: data["Fortpflanzung"]!,
      iconData: FontAwesomeIcons.venusMars,
      tasks: tasks["Fortpflanzung"]!),
];
