import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Planung": [
    Column(
      children: [
        const Text("""
Metakognitive Strategien sind auf die Steuerung und Kontrolle der kognitiven Strategien ausgerichtet.\n
Bei der Planung soll festgestellt werden, welches Ziel angestrebt wird und wie es erreicht werden kann.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Überwachung": [
    Column(
      children: [
        const Text("""
Die Überwachung korrigiert eine Aufgabenbearbeitung und begleitet den eigenen Bearbeitungsfortschritt kritisch.\n
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Regulation": [
    Column(
      children: [
        const Text("""
Die Prozesse der Regulation steuern das Verstehen und Behalten.\n
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Bewertung": [],
};

Map<String, List<Task>> tasks = {
  "Planung": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Effizienzziele des Lernens (nur 3 Stunden investieren): {} .",
        correctAnswer: "Sekundäre Ziele",
        answers: [
          "Primäre Ziele",
          "Sekundäre Ziele",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Die eigentlichen Planungsziele (Text durcharbeiten): {} .",
        correctAnswer: "Primäre Ziele",
        answers: [
          "Primäre Ziele",
          "Sekundäre Ziele",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Zudem soll bei der Planung ein {} erstellt und Ressourcen eingeschätzt werden.",
        correctAnswer: "Handlungsplan",
        answers: []),
  ],
  "Überwachung": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Funktion der Überwachung liegt im Sammeln von Infos über den erreichten {} und das {}.",
        correctAnswer: "Lernstand{}Verständnisniveau",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Die Überwachung überwacht die Weiterentwicklung bei der {} und sagt vorher, welches Ergebnis wohl erzielt wird.",
        correctAnswer: "Aufgabenlösung",
        answers: [
          "Aufgabenlösung",
          "Aufgabenerstellung",
        ]),
  ],
  "Regulation": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Regulationsprozesse tragen dazu bei...\ndie Ressourcen für eine Aufgabenbearbeitung klarer zu definieren.",
        correctAnswer: "Ressourcen",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Regulationsprozesse tragen dazu bei...\neine konkrete Abfolge von Schritten für die Bearbeitung festzulegen.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Regulationsprozesse tragen dazu bei...\nIntensität und {} des strategischen Vorgehens genauer zu bestimmen.",
        correctAnswer: "die Geschwindigkeit",
        answers: [
          "die Geschwindigkeit",
          "die Bereitschaft",
        ]),
  ],
  "Bewertung": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Die Bewertung erfolgt {} Beendigung einer Lernaufgabe",
        correctAnswer: "nach",
        answers: [
          "nach",
          "vor",
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Die Bewertung hat keinen Einfluss auf zukünftige Aufgaben.",
        correctAnswer: "Falsch",
        answers: [
          "Wahr",
          "Falsch",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Das Bewerten trägt zu einer ständigen {} des Lernprozesse und strategischen Expertise bei.",
        correctAnswer: "Verbesserung",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Welche Frage wird bei der Bewertung beantwortet?",
        correctAnswer: "War der Zeitplan einhaltbar?",
        answers: [
          "Wie habe ich die Strategien umgesetzt?",
          "War der Zeitplan einhaltbar?",
          "War die Aufgabe zu schwierig?"
        ]),
  ],
};

List<LearningBite> metacognitiveLearningBites = [
  LearningBite(
      name: "Planung",
      type: LearningBiteType.lesson,
      data: data["Planung"]!,
      iconData: FontAwesomeIcons.map,
      tasks: tasks["Planung"]!),
  LearningBite(
      name: "Überwachung",
      type: LearningBiteType.lesson,
      data: data["Überwachung"]!,
      iconData: FontAwesomeIcons.watchmanMonitoring,
      tasks: tasks["Überwachung"]!),
  LearningBite(
      name: "Regulation",
      type: LearningBiteType.lesson,
      data: data["Regulation"]!,
      iconData: FontAwesomeIcons.gears,
      tasks: tasks["Regulation"]!),
  LearningBite(
      name: "Bewertung",
      type: LearningBiteType.lesson,
      data: data["Bewertung"]!,
      iconData: FontAwesomeIcons.award,
      tasks: tasks["Bewertung"]!),
];
