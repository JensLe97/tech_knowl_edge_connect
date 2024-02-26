import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Einführung in Lernstrategien": [
    Column(
      children: [
        const Text("""
Eine Strategie besteht aus einer kognitiven Operation, die zwangsläufig beim Bearbeiten einer Aufgabe stattfindenden Prozessen übergeordnet ist.\n
Strategien dienen kognitiven Zielen und sind potentiell bewusste und kontrollierbare Aktivitäten.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Es lassen sich 5 Merkmale von Strategien benennen:\n
    1. Absichtlich
    2. (Bewusst)
    3. (Spontan)
    4. vom Lernenden ausgewählt
    5. vom Lernenden kontrolliert
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Mnemonische Strategien": [
    Column(
      children: [
        const Text("""
Mnemonische Strategien sind Techniken, die dabei helfen, neue Informationen im Arbeitsgedächtnis zu halten, um eine Verknüpfung mit vorhandenem Vorwissen zu unterstützen\n
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Es lassen sich drei Beweggründe unterscheiden:\n
    1. Intrinsische Motivation
    2. Extrinsische Motivation
    3. Amotivation
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Strukturierende Strategien": [
    Column(
      children: [
        const Text("""
Strukturierende Strategien zielen auf interne Verknüpfungen und Strukturen des Lernmaterials ab.\n
Relevante Informationen sollen herausgesucht werden und behaltensförderlich organisiert und gruppiert werden
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Generative Strategien": [
    Column(
      children: [
        const Text("""
Generative Strategien haben zum Ziel, ein tieferes Verständnis zu erzeugen.\n
Es sollen aktiv Beziehungen zwischen Ideen bzw. Informationen hergestellt ('generiert') werden.
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
  "Einführung in Lernstrategien": [
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Unter Lernstrategien versteht man Prozesse bzw. Aktivitäten, die auf ein Lern- oder Behaltensziel ausgerichtet sind.\nSie weisen wenigstens eine zusätzliche Eigenschaft auf: intentional, bewusst, spontan, selektiv und {}.",
        correctAnswer: "kontrolliert",
        answers: [
          "kontrolliert",
          "unkontrolliert",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Man unterscheidet zwischen {} Strategien, Metakognitiven Strategien und Stützstrategien des externen Ressourcenmanagements.",
        correctAnswer: "kognitiven",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Stützstrategien oder sekundäre Strategien zielen darauf ab, die Lernumwelt zu optimieren. Dazu gehört die Gestaltung des {} Strategien, Metakognitiven Strategien und Stützstrategien des externen Ressourcenmanagements.",
        correctAnswer: "Arbeitsplatzes",
        answers: ["Arbeitsplatzes", "Arbeitsgedächtnisses"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Bei kognitiven Strategien wird unterschieden zwischen: {}- oder Wiederholungsstrategien sowie Organisations- und {}strategien.",
        correctAnswer: "Memorier{}Elaborations",
        answers: []),
  ],
  "Mnemonische Strategien": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Pures Wiederholen von Informationen (Auswendiglernen) ist eine Mnemotechnik.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Dadurch erfolgt eine leichtere Informationsübertragung ins {}.",
        correctAnswer: "Langzeitgedächtnis",
        answers: ["Arbeitsgedächtnis", "Langzeitgedächtnis"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Akustische und bildliche Brücken bauen, z.B. Bean mit Biene verknüpfen, nennt man: {}.",
        correctAnswer: "Schlüsselwortmethode",
        answers: ["Wahr", "Falsch"]),
  ],
  "Strukturierende Strategien": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Bespiele für Strukturstrategien sind die Konstruktion mentaler Modelle bzw. netzartig geordnete Wissensstrukturen, genannt {}.",
        correctAnswer: "Mapping",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Anfertigen zusammenfassender Exzerpte, genannt: {}.",
        correctAnswer: "Outlining",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Texte werden in {} in zeitlich und funktionale Beziehungen zusammengefasst.",
        correctAnswer: "Flussdiagrammen",
        answers: ["Wasserfall-Diagrammen", "Flussdiagrammen"]),
  ],
  "Generative Strategien": [
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Bei generativen Strategien geht es um eine {} relevanter Informationen und Maßnahmen der Verknüpfung mit verfügbarem Wissen.",
        correctAnswer: "Elaboration",
        answers: ["Elaboration", "Reduktion"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Blutkreislauf mit Röhrensystem von Wasser verdeutlichen.",
        correctAnswer: "Analogiebildung",
        answers: ["Selbstbefragung", "Analogiebildung"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Fragen an einen Text generieren und diese beantworten.",
        correctAnswer: "Selbstbefragung",
        answers: ["Selbstbefragung", "Analogiebildung"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welche dieser Strategien nach Brod (2021) erweisen sich für die Grundschule als NICHT effektiv?",
        correctAnswer: "Generieren von Erklärungen (questioning)",
        answers: [
          "Kartieren von Konzeption (concept mapping)",
          "Generieren von Vorhersagen (predicting)",
          "Generieren von Erklärungen (questioning)",
          "Generieren von Antworten (testing)",
        ]),
  ]
};

List<LearningBite> cognitiveLearningBites = [
  LearningBite(
      name: "Einführung in Lernstrategien",
      type: LearningBiteType.lesson,
      data: data["Einführung in Lernstrategien"]!,
      iconData: FontAwesomeIcons.info,
      tasks: tasks["Einführung in Lernstrategien"]!),
  LearningBite(
      name: "Mnemonische Strategien",
      type: LearningBiteType.lesson,
      data: data["Mnemonische Strategien"]!,
      iconData: FontAwesomeIcons.brain,
      tasks: tasks["Mnemonische Strategien"]!),
  LearningBite(
      name: "Strukturierende Strategien",
      type: LearningBiteType.lesson,
      data: data["Strukturierende Strategien"]!,
      iconData: FontAwesomeIcons.trowelBricks,
      tasks: tasks["Strukturierende Strategien"]!),
  LearningBite(
      name: "Generative Strategien",
      type: LearningBiteType.lesson,
      data: data["Generative Strategien"]!,
      iconData: FontAwesomeIcons.wandMagicSparkles,
      tasks: tasks["Generative Strategien"]!),
];
