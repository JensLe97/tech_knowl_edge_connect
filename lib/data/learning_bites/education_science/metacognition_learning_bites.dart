import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Metakognitive Kompetenzen": [
    Column(
      children: [
        const Text("""
Metakognition umfasst Phänomene, Aktivitäten und Erfahrungen, die mit dem Wissen und der Kontrolle über eigene kognitive Funktionen zu tun haben.\n
Zwei-Komponenten-Sichtweise:
    1. Wissen über eigene kognitive Fähigkeiten (deklarativ)
    2. Kontrolle der eigenen kognitiven Aktivitäten (prozedural)
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Strategieerwerb": [
    Column(
      children: [
        const Text("""
Einzelene Behaltenstrategien bilden sich bereits in der Grundschul aus, erworben werden (metakognitive) Strategien aber erst im höheren Alter.\n
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
  "Metakognitive Kompetenzen": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nWissen über aktuelle Gedächtniszustände bzw. Lernbereitschaften",
        correctAnswer: "Epistemisches Wissen",
        answers: [
          "Systemisches Wissen",
          "Epistemisches Wissen",
          "Exekutive Prozesse",
          "Sensitiät kognitiver Aktiviäten",
          "Metakognitive Erfahrungen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nBewusste kognitive Empfindungen und affektive Zustände",
        correctAnswer: "Metakognitive Erfahrungen",
        answers: [
          "Systemisches Wissen",
          "Epistemisches Wissen",
          "Exekutive Prozesse",
          "Sensitiät kognitiver Aktiviäten",
          "Metakognitive Erfahrungen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nPlanung, Überwachung und Steuerung eigener Lernprozesse",
        correctAnswer: "Exekutive Prozesse",
        answers: [
          "Systemisches Wissen",
          "Epistemisches Wissen",
          "Exekutive Prozesse",
          "Sensitiät kognitiver Aktiviäten",
          "Metakognitive Erfahrungen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nWissen über Lernanforderungen und Strategien",
        correctAnswer: "Systemisches Wissen",
        answers: [
          "Systemisches Wissen",
          "Epistemisches Wissen",
          "Exekutive Prozesse",
          "Sensitiät kognitiver Aktiviäten",
          "Metakognitive Erfahrungen"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nErfahrungswissen und Intuition",
        correctAnswer: "Sensitiät kognitiver Aktiviäten",
        answers: [
          "Systemisches Wissen",
          "Epistemisches Wissen",
          "Exekutive Prozesse",
          "Sensitiät kognitiver Aktiviäten",
          "Metakognitive Erfahrungen"
        ]),
  ],
  "Strategieerwerb": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Wann werden basale Behaltensstrategien, wie das Wiederholen und Kategorisieren von Informationen, erworben?",
        correctAnswer: "Primarstufe",
        answers: ["Primarstufe", "Sekundarstufe I", "Sekundarstufe II"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Im ersten Stadium des Strategieerwerbs können Kinder keine Strategien spontan hervorrufen oder übernehmen: {}.",
        correctAnswer: "Mediationsdefizit",
        answers: [
          "Mediationsdefizit",
          "Produktionsdefizit",
          "Nutzungsdefizit"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Im zweiten Stadium des Strategieerwerbs können Kinder keine Strategien spontan hervorrufen, aber nach Hinweisen übernehmen: {}.",
        correctAnswer: "Produktionsdefizit",
        answers: [
          "Mediationsdefizit",
          "Produktionsdefizit",
          "Nutzungsdefizit"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Im dritten Stadium des Strategieerwerbs können Kinder Strategien spontan nutzen, was sich aber noch nicht günstig auf die Lernleistung auswirkt: {}.",
        correctAnswer: "Nutzungsdefizit",
        answers: [
          "Mediationsdefizit",
          "Produktionsdefizit",
          "Nutzungsdefizit"
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Ineffizienz der Strategienutzung kommt durch unzureichende {} oder mangelde {} dafür, wann die Strategie wirkungsvoll einsetzbar ist.",
        correctAnswer: "Automatisierung{}Sensitivität",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Wenn der erhoffte Nutzen sich nicht erkennen lässt, kann es zu einer '{} der Motivation' einem '{}' oder kommen.",
        correctAnswer: "Durststrecke{}Motivationstal",
        answers: []),
  ],
};

List<LearningBite> metacognitionLearningBites = [
  LearningBite(
      name: "Metakognitive Kompetenzen",
      type: LearningBiteType.lesson,
      data: data["Metakognitive Kompetenzen"]!,
      iconData: FontAwesomeIcons.gear,
      tasks: tasks["Metakognitive Kompetenzen"]!),
  LearningBite(
      name: "Strategieerwerb",
      type: LearningBiteType.lesson,
      data: data["Strategieerwerb"]!,
      iconData: FontAwesomeIcons.chartLine,
      tasks: tasks["Strategieerwerb"]!),
];
