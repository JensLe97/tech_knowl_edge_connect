import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Ressourcenverbrauch": [
    Column(
      children: [
        const Text("""
Die Verarbeitung von Informationen findet in einem kapazitätsbegrenzten System statt.\n
Es müssen Mechanismen angenommen werden, die aufgabenbezogene Selektionsprozesse (Aufmerksamkeit) leisten können.
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Kognitive Entwicklungsstufen": [
    Column(
      children: [
        const Text("""
Die 4 Stufen der kognitiven Entwicklung nach Piaget (Garz, 2006) lauten:\n
    1. senso-motorische Stufe (0-2 Jahre)
    2. prä-operatorische Stufe (2-7 Jahre)
    3. konkret-operatorische Stufe (7-11 Jahre)
    4. formal-operatorische Stufe (an 11 Jahren)
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
  "Ressourcenverbrauch": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Lernen ein ressourcenbeanspruchender Prozess des Aufbaus mentaler Konstruktionen. Dieser Ressourcenverbrauch ist in der {} theory beschrieben",
        correctAnswer: "cognitive load",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nRessourcenbeanspruchung aus der Komplexität (element interactivity) des Lernstoffs",
        correctAnswer: "intrisic cognitive load",
        answers: [
          "intrisic cognitive load",
          "extraneous cognitive load",
          "germane cognitive load",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nRessourcenbeanspruchung aus der Art, wie der Sachverhalt dem Lernenden angeboten wird",
        correctAnswer: "extraneous cognitive load",
        answers: [
          "intrisic cognitive load",
          "extraneous cognitive load",
          "germane cognitive load",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nRessourcenbeanspruchung, die für den Lernprozess notwendig ist, um das Lernmaterial zu verstehen",
        correctAnswer: "germane cognitive load",
        answers: [
          "intrisic cognitive load",
          "extraneous cognitive load",
          "germane cognitive load",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Wenn die Menge der benötigten Ressourcen, das Ausmaß der verfügbaren Kapazität (cognitive capacity) übersteigen, spricht man von {}.",
        correctAnswer: "cognitive overload",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Es sollte auf {}, irrelevante Dinge verzichtet werden, um Ressourcen zu sparen.",
        correctAnswer: "lernunwichtige",
        answers: ["wichtige", "lernunwichtige"]),
  ],
  "Kognitive Entwicklungsstufen": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "In der senso-motorischen Stufe bezieht das Kind ersteinmal alles nur auf sich ({}) und wendet sich dann zur {}.",
        correctAnswer: "Egozentrismus{}Sozialität",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Entdeckung neuer Mittel durch Ausprobieren und tertiäre Zirkulation.",
        correctAnswer: "5. Stadium (12-18 Monate)",
        answers: [
          "1. Stadium (0-1 Monat)",
          "2. Stadium (1-4 Monate)",
          "3. Stadium (4-8 Monate)",
          "4. Stadium (8-12 Monate)",
          "5. Stadium (12-18 Monate)",
          "6. Stadium (18-24 Monate)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Erste Erwerbungen und die primäre Zirkulärreaktion.",
        correctAnswer: "2. Stadium (1-4 Monate)",
        answers: [
          "1. Stadium (0-1 Monat)",
          "2. Stadium (1-4 Monate)",
          "3. Stadium (4-8 Monate)",
          "4. Stadium (8-12 Monate)",
          "5. Stadium (12-18 Monate)",
          "6. Stadium (18-24 Monate)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Erfinden neuer Mittel durch geistige Kombination.",
        correctAnswer: "6. Stadium (18-24 Monate)",
        answers: [
          "1. Stadium (0-1 Monat)",
          "2. Stadium (1-4 Monate)",
          "3. Stadium (4-8 Monate)",
          "4. Stadium (8-12 Monate)",
          "5. Stadium (12-18 Monate)",
          "6. Stadium (18-24 Monate)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Sekundäre Zirkulärreaktionen und interessant Erscheinungen andauern lassen.",
        correctAnswer: "3. Stadium (4-8 Monate)",
        answers: [
          "1. Stadium (0-1 Monat)",
          "2. Stadium (1-4 Monate)",
          "3. Stadium (4-8 Monate)",
          "4. Stadium (8-12 Monate)",
          "5. Stadium (12-18 Monate)",
          "6. Stadium (18-24 Monate)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Koordination von Zielen und Mitteln",
        correctAnswer: "4. Stadium (8-12 Monate)",
        answers: [
          "1. Stadium (0-1 Monat)",
          "2. Stadium (1-4 Monate)",
          "3. Stadium (4-8 Monate)",
          "4. Stadium (8-12 Monate)",
          "5. Stadium (12-18 Monate)",
          "6. Stadium (18-24 Monate)"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "In der präoperatorischen Stufe zeigt sich eine {} im Denken des Kindes, denn es ist Philosoph und hat eigenständige Gedanken und Vorstellungen über die Welt.",
        correctAnswer: "Ambivalenz",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "In der konkret-operatorischen Stufe können sich Kinder von unmittelbaren Anschauungen lösen und das Denken wird {}.",
        correctAnswer: "konkreter",
        answers: ["konkreter", "abstrakter"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Das charakteristische Merkmal für die 3. Stufe ist die {}.",
        correctAnswer: "Reversibilität",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Kinder sind jetzt in der Lage, {} Konzepte wie Zeit, Raum, Mengen und Ursache-Wirkungsbeziehungen zu verstehen.",
        correctAnswer: "abstrakte",
        answers: ["abstrakte", "konkrete"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Kinder können abstrakte Kategorien bilden, auf konkrete Situationen anwenden und Lernstrategien verwenden.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
  ],
};

List<LearningBite> attentionStrategiesLearningBites = [
  LearningBite(
      name: "Ressourcenverbrauch",
      type: LearningBiteType.lesson,
      data: data["Ressourcenverbrauch"]!,
      iconData: FontAwesomeIcons.batteryQuarter,
      tasks: tasks["Ressourcenverbrauch"]!),
  LearningBite(
      name: "Kognitive Entwicklungsstufen",
      type: LearningBiteType.lesson,
      data: data["Kognitive Entwicklungsstufen"]!,
      iconData: FontAwesomeIcons.stairs,
      tasks: tasks["Kognitive Entwicklungsstufen"]!),
];
