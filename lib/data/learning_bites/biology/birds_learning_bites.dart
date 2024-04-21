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
Vögel haben diese Ähnlichkeiten mit Reptilien:\n
  1. Dotterreiche Eier
  2. Harnsäureausscheidung
  3. Beschuppte Beine
  4. Federn aus β-Keratin
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
Weiter Merkmale:\n
  1. Gleichwarm
  2. Flügel als Vordergliedmaßen 
  3. Atmung über Lungen
  4. 2-beinig laufend
  5. Innere Befruchtung und Eier legen (ovipar)
  6. Kloake: Ausgänge von Darm, Harnröhre und Geschlechtsorganen
  7. Bürzeldrüse (einzige Drüse zum Einfetten des Gefieders)
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
};

Map<String, List<Task>> tasks = {
  "Fachbegriffe": [
    Task(
      type: TaskType.indexCard,
      question: "Synapsiden",
      correctAnswer: "Säugetiere",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Kloakentiere",
      correctAnswer: "Monotremata",
    ),
  ],
};

List<LearningBite> birdsLearningBites = [
  LearningBite(
    name: "Allgemeine Merkmale",
    type: LearningBiteType.text,
    data: data["Allgemeine Merkmale"]!,
    iconData: FontAwesomeIcons.dove,
  ),
  LearningBite(
      name: "Fachbegriffe",
      type: LearningBiteType.lesson,
      data: [],
      iconData: FontAwesomeIcons.checkDouble,
      tasks: tasks["Fachbegriffe"]!),
];
