import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Texte zusammenfassen": [
    Column(
      children: [
        const Text("""
Texte zusammenfassen ist eine multifunktionale Fertigkeit, die Kompetenzen des Lesens und Schreibens erfordert.\n
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Wissensschemata": [
    Column(
      children: [
        const Text("""
Schemata sind übergeordnete kognitive Strukturen (allgemeine Wissensstrukturen) von Gegenständen, Situationen und Inhalten.\n
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Externe Visualisierung": [
    Column(
      children: [
        const Text("""
Externe Visualisierung hat die Funktion der Tiefenverarbeitung und kann...\n
    1. der Organisation des Lernstoffs
    2. der Reduktion
    3. der Elaboration
dienen.
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
  "Texte zusammenfassen": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Sie dient der kognitiven Bewältigung der {}, dem tieferen Verstehen und dem {} Behalten.",
        correctAnswer: "Informationsflut{}langfristigen",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Bedingung des Zusammenfassens ist das Erkennen der {} und {} von Textaussagen.",
        correctAnswer: "Wichtigkeiten{}Unwichtigkeiten",
        answers: []),
  ],
  "Wissensschemata": [
    Task(
        type: TaskType.singleChoice,
        question: "Durch bestimmte Stimuli wird ein Schemata aktiviert.",
        correctAnswer: "Bottom-up",
        answers: ["Top-down", "Bottom-up"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die kognitive Verarbeitung findet durch ein vorher aktiviertes Schemata statt.",
        correctAnswer: "Top-down",
        answers: ["Top-down", "Bottom-up"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Weiterentwicklung des Schemas durch strukturelle Veränderungen.",
        correctAnswer: "Feinabstimmung (tuning)",
        answers: [
          "Wissenszuwachs (accretion)",
          "Feinabstimmung (tuning)",
          "Umstrukturierung (restructuring)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Bestehende Leerstellen werden mit Infos angereichert.",
        correctAnswer: "Wissenszuwachs (accretion)",
        answers: [
          "Wissenszuwachs (accretion)",
          "Feinabstimmung (tuning)",
          "Umstrukturierung (restructuring)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ein neues Schema wird gebildet.",
        correctAnswer: "Umstrukturierung (restructuring)",
        answers: [
          "Wissenszuwachs (accretion)",
          "Feinabstimmung (tuning)",
          "Umstrukturierung (restructuring)"
        ]),
  ],
  "Externe Visualisierung": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu die Mapping-Technik zu:\nGeordnete und hierarchisch aufgebaute Gebilde.",
        correctAnswer: "Concept Map",
        answers: ["Mind Map", "Concept Map"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu die Mapping-Technik zu:\nVon einem zentralen Schlüsselbegriff strahlen mehrere Äste aus.",
        correctAnswer: "Mind Map",
        answers: ["Mind Map", "Concept Map"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu die Mapping-Technik zu:\nBeziehungen zwischen Schlüsselbegriffen werden explizit benannt.",
        correctAnswer: "Concept Map",
        answers: ["Mind Map", "Concept Map"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu die Mapping-Technik zu:\nBeziehungen bleiben unbestimmt.",
        correctAnswer: "Mind Map",
        answers: ["Mind Map", "Concept Map"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu die Mapping-Technik zu:\nDie dicken Äste verzweigen sich mit dünnen Ästen.",
        correctAnswer: "Mind Map",
        answers: ["Mind Map", "Concept Map"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu die Mapping-Technik zu:\nVerbindungslinien zwischen Ober- und Unterbegriffen, aber auch Querverbindungen.",
        correctAnswer: "Concept Map",
        answers: ["Mind Map", "Concept Map"]),
  ],
};

List<LearningBite> organizationStrategiesLearningBites = [
  LearningBite(
      name: "Texte zusammenfassen",
      type: LearningBiteType.lesson,
      data: data["Texte zusammenfassen"]!,
      iconData: FontAwesomeIcons.pencil,
      tasks: tasks["Texte zusammenfassen"]!),
  LearningBite(
      name: "Wissensschemata",
      type: LearningBiteType.lesson,
      data: data["Wissensschemata"]!,
      iconData: FontAwesomeIcons.tableColumns,
      tasks: tasks["Wissensschemata"]!),
  LearningBite(
      name: "Externe Visualisierung",
      type: LearningBiteType.lesson,
      data: data["Externe Visualisierung"]!,
      iconData: FontAwesomeIcons.diagramProject,
      tasks: tasks["Externe Visualisierung"]!),
];
