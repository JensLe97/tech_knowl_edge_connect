import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Lerntypen und Lernstile": [
    Column(
      children: [
        const Text("""
Unter Lernstilen versteht man persönlichkeitsabhängige Vorlieben des Wahrnehmens, Erinnerns, Denkens und Problemlösens.\n
Die bekanntesten Stile sind:\n
    1. Impulsivität vs. Reflexivität
    2. Feldabhängigkeit vs. Feldunabhängigkeit
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Verarbeitungspräferenzen": [
    Column(
      children: [
        const Text("""
Schmeck (1988) unterscheidet zwischen Verarbeitungspräferenzen:\n
    1. tiefe Verarbeitungspräferenz
    2. elaborative Verarbeitungspräferenz
    3. oberflächlicheVerarbeitungspräferenz
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
  "Lerntypen und Lernstile": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Personen...\ntendieren dazu, visuelle Muster ganzheitlich wahrzunehmen.",
        correctAnswer: "Feldabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
    Task(
        type: TaskType.singleChoice,
        question: "Personen...\nkönnen Muster komponentenweise analysieren.",
        correctAnswer: "Feldunabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Personen...\nhaben Probleme, wichtige Details zu erkennen und zu fokussieren.",
        correctAnswer: "Feldabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Personen...\nfällt es schwerer den einsatz von Lernstrategien selbst zu überwachen.",
        correctAnswer: "Feldabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Personen...\ninteressieren sich häufig für Mathematik und Naturwissenschaften.",
        correctAnswer: "Feldunabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Personen...\narbeiten gut in Gruppen und interessieren sich häufig für Literatur und Geschichte.",
        correctAnswer: "Feldabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Personen...\nüberwachen ihre eigenen Informationsverarbeitungsprozesse",
        correctAnswer: "Feldunabhängig",
        answers: ["Feldabhängig", "Feldunabhängig"]),
  ],
  "Verarbeitungspräferenzen": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Lerner benutzen hauptsächlich einfache Memorierungsstrategien.",
        correctAnswer: "oberflächliche Verarbeitungspräferenz",
        answers: [
          "tiefe Verarbeitungspräferenz",
          "elaborative Verarbeitungspräferenz",
          "oberflächliche Verarbeitungspräferenz"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Beim Wissenserwerb wird kritisch vorgegangen und konzeptuell-organisierende Strategien bevorzugt.",
        correctAnswer: "tiefe Verarbeitungspräferenz",
        answers: [
          "tiefe Verarbeitungspräferenz",
          "elaborative Verarbeitungspräferenz",
          "oberflächliche Verarbeitungspräferenz"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Es wird eine Verknüpfung der neuen Lerninhalte mit persönlichen Erfahrungen hergestellt.",
        correctAnswer: "elaborative Verarbeitungspräferenz",
        answers: [
          "tiefe Verarbeitungspräferenz",
          "elaborative Verarbeitungspräferenz",
          "oberflächliche Verarbeitungspräferenz"
        ]),
  ]
};

List<LearningBite> learnTypesStylesLearningBites = [
  LearningBite(
      name: "Lerntypen und Lernstile",
      type: LearningBiteType.lesson,
      data: data["Lerntypen und Lernstile"]!,
      iconData: FontAwesomeIcons.eye,
      tasks: tasks["Lerntypen und Lernstile"]!),
  LearningBite(
      name: "Verarbeitungspräferenzen",
      type: LearningBiteType.lesson,
      data: data["Verarbeitungspräferenzen"]!,
      iconData: FontAwesomeIcons.star,
      tasks: tasks["Verarbeitungspräferenzen"]!),
];
