import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Dimensionen von Vorwissen": [
    Column(
      children: [
        const Text("""
Vorwissen ist multidimensional und interaktiv.\n
Nach Dochy und Alexander (1995) ist Vorwissen das gesamte Wissen einer Person, das:\n
    1. dynamischer Natur ist
    2. vor der Bearbeitung einer Lernaufgabe zur Verfügung steht
    3. strukturiert ist
    4. in unterschiedlichen Formen vorliegt
    5. zum Teil explizit und zum Teil implizit ist
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
Die Dimensionen von Vorwissen sind:\n
    1. Inhalt
    2. Bewusstheit
    3. Repräsentation
    4. Wissenschaftlichkeit
    5. Umfang
    6. Handlungsrelevanz
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Vorwissensaktivierung": [
    Column(
      children: [
        const Text("""
Offene Vorwissensaktivierung zielt auf die allgemeine Aktivierung von Wissensbeständen, Erfahrungen und Ideen zu einem Thema an.
Fokussiertere Vorwissensaktivierung zielt auf die spezifische Aktivierung von Wissenselementen, zu einem bestimmten Thema (z.B. Mathe) ab.\n
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
  "Dimensionen von Vorwissen": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Inhalt: Worauf bezieht sich das Vorwissen:\nAuf Handlungen und Fertigkeiten (das Können)",
        correctAnswer: "Prozedurales Wissen",
        answers: [
          "Deklaratives Wissen",
          "Prozedurales Wissen",
          "Konditionales Wissen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Inhalt: Worauf bezieht sich das Vorwissen:\nWissen über Fakten Bedeutungen von Symbolen",
        correctAnswer: "Deklaratives Wissen",
        answers: [
          "Deklaratives Wissen",
          "Prozedurales Wissen",
          "Konditionales Wissen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Inhalt: Worauf bezieht sich das Vorwissen:\nIn welcher Situation ein bestimmtes Wissen zur Anwendung kommen sollte.",
        correctAnswer: "Konditionales Wissen",
        answers: [
          "Deklaratives Wissen",
          "Prozedurales Wissen",
          "Konditionales Wissen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bewusstheit: Wissen ist nicht oder nur schwer verbalisierbar und wird automatisch und unbewusst aktiviert",
        correctAnswer: "Implizites Wissen",
        answers: [
          "Explizites Wissen",
          "Implizites Wissen",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bewusstheit: Wissen ist verbalisierbar und bewusst aktiviert",
        correctAnswer: "Explizites Wissen",
        answers: [
          "Explizites Wissen",
          "Implizites Wissen",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Repräsentation: Form, in der das Vorwissen vorliegt:\nWissensstrukturen, in denen Zusammenhänge eines Realitätsbereichs repräsentiert sind",
        correctAnswer: "Schemata",
        answers: [
          "Analoge Repräsentation",
          "Mentale Modelle",
          "Schemata",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Repräsentation: Form, in der das Vorwissen vorliegt:\nAbbildungen, die die Merkmale eines Objektes beibehalten, also den äußeren Gegebenheiten ähneln",
        correctAnswer: "Analoge Repräsentation",
        answers: [
          "Analoge Repräsentation",
          "Mentale Modelle",
          "Schemata",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Repräsentation: Form, in der das Vorwissen vorliegt:\nÄhnlichkeiten sind eher strukturell",
        correctAnswer: "Mentale Modelle",
        answers: [
          "Analoge Repräsentation",
          "Mentale Modelle",
          "Schemata",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Vorwissensaktivierung ist der Abruf gespeicherter Informationen aus dem {} und die Bereithaltung der Informationen im {}.",
        correctAnswer: "Langzeitgedächtnis{}Arbeitsgedächtnis",
        answers: []),
  ],
  "Vorwissensaktivierung": [
    Task(
        type: TaskType.singleChoice,
        question: "Brainstorming: Assoziationstechnik zur Ideenfindung.",
        correctAnswer: "Offene Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Analogien: Rationale Strukturen, die von einem Gebiet auf ein anderes übertragen werden.",
        correctAnswer: "Fokussiertere Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Mapping-Verfahren: Wissensstrukturen grafisch darstellen.",
        correctAnswer: "Offene Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Erfahrungen berichten lassen: Wissenschaftliche Elemente, subjektive Theorien und Fehlkonzepte aktivieren.",
        correctAnswer: "Offene Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Kognitive Vorstrukturierung: Vor dem Lernen strukturierende Infos (Advanced Organizer) präsentieren.",
        correctAnswer: "Fokussiertere Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Hypothesen, Erklärungen: Beispiele generieren lassen.",
        correctAnswer: "Offene Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Beispiele und Falldarstellungen: Abstrakte Sachverhalte anhand von konkreten Beispielen veranschaulichen.",
        correctAnswer: "Fokussiertere Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Fragenstellen: Bezug zu vorhergehenden Lektionen direkt herstellen.",
        correctAnswer: "Fokussiertere Vorwissensaktivierung",
        answers: [
          "Offene Vorwissensaktivierung",
          "Fokussiertere Vorwissensaktivierung",
        ]),
  ]
};

List<LearningBite> activationStrategiesLearningBites = [
  LearningBite(
      name: "Dimensionen von Vorwissen",
      type: LearningBiteType.lesson,
      data: data["Dimensionen von Vorwissen"]!,
      iconData: FontAwesomeIcons.cubes,
      tasks: tasks["Dimensionen von Vorwissen"]!),
  LearningBite(
      name: "Vorwissensaktivierung",
      type: LearningBiteType.lesson,
      data: data["Vorwissensaktivierung"]!,
      iconData: FontAwesomeIcons.lightbulb,
      tasks: tasks["Vorwissensaktivierung"]!),
];
