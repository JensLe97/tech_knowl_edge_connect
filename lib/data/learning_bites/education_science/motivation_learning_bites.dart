import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Motivation erklärt": [
    Column(
      children: [
        const Text("""
Motivation kann als Bedingung des Lern- und Leistungsverhaltens im Unterricht angesehen werden.\n
Der Begriff leitet sich vom lateinischen Verb "movere" (bewegen) ab, also eine Art Handlungsantrieb.
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Rubikon-Modell": [
    Column(
      children: [
        const Text("""
Das Rubikon-Modell der Handlungsphasen unterteilt 4 Phasen:\n
    1. Abwägen
    2. Planen
    3. Handeln
    4. Bewerten
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Diese lassen sich auch wie folgt beschreiben:\n
    1. Prädezisionale Phase
    2. Präaktionale Phase
    3. Aktionale Phase
    4. Postaktionale Phase
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
  "Motivation erklärt": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Motivation ist ein psychologischer Prozess, der die {}, {} und {} zielgerichteten Handels beeinflusst.",
        correctAnswer: "Initiierung{}Ausrichtung{}Aufrechterhaltung",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Zusätzlich beeinflusst wird die {}, {} und {} zielgerichteten Handelns.",
        correctAnswer: "Steuerung{}Qualität{}Bewertung",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Motivation ist im {} Handlungsverlauf von Relevanz.",
        correctAnswer: "gesamten",
        answers: ["gesamten", "anfänglichen"]),
  ],
  "Rubikon-Modell": [
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "In der prädezisionalen Phase bewerten Personen, wie bedeutsam das Erreichen eines gewünschten Zustandes ist. Das wird auch {} genannt.",
        correctAnswer: "Wertkomponente",
        answers: ["Erwartungskomponente", "Wertkomponente"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Inwiefern sie das Gewünschte herbeiführen können, wird hingegen als {} bezeichnet.",
        correctAnswer: "Erwartungskomponente",
        answers: ["Erwartungskomponente", "Wertkomponente"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Motivation im Handlungsverlauf ist immer beeinflusst von Merkmalen der {} und {}.",
        correctAnswer: "Person{}Situation",
        answers: []),
  ],
};

List<LearningBite> motivationLearningBites = [
  LearningBite(
      name: "Motivation erklärt",
      type: LearningBiteType.lesson,
      data: data["Motivation erklärt"]!,
      iconData: FontAwesomeIcons.thumbsUp,
      tasks: tasks["Motivation erklärt"]!),
  LearningBite(
      name: "Rubikon-Modell",
      type: LearningBiteType.lesson,
      data: data["Rubikon-Modell"]!,
      iconData: FontAwesomeIcons.diagramSuccessor,
      tasks: tasks["Rubikon-Modell"]!),
];
