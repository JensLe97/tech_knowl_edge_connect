import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Reattributionstrainings": [
    Column(
      children: [
        const Text("""
Motivationstrainings werden häufig mit der Vermittlung von Fachwissen und Lernstrategien kombiniert, da Wissenslücken gefüllt werden müssen.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Münchner Motivationstraining": [
    Column(
      children: [
        const Text("""
Dieses Training addressiert verschiedene motivationale Komponenten.\n
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
Schüler und Schülerinnen...\n
    1. erhalten motivational günstiges Feedback
    2. lernen Erfolge und Misserfolge attributional zu attribuieren
    3. entwickeln Lernstrategien
    4. entwickeln die Überzeugung, eigene Fähigkeiten verändern zu können
    5. und das Gelernte über verschiedene Fächer hinweg zu generalieren
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Training nach Rheinberg und Krug": [
    Column(
      children: [
        const Text("""
Ziel hierbei ist, das Fähigkeitsselbstkonzept und Erfolgserwartung zu stärken und günstige Attributionen für Erfolg und Misserfolg zu fördern.\n
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
  "Reattributionstrainings": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Wenn motivationsabträgliche durch motivationsförderliche Attributionen (Ursachenzuschreibungen) ersetzt werden, spricht man von {}.",
        correctAnswer: "Reattributionstraining",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Dies wird häufig durch attributionales {} gemacht.",
        correctAnswer: "Feedback",
        answers: ["Aufschreiben", "Feedback"]),
    Task(
        type: TaskType.singleChoice,
        question: "'Diese Aufgabe war in der Tat nicht leicht.'",
        correctAnswer: "Schwierige Aufgabenstellung",
        answers: [
          "Hohe Fähigkeiten",
          "Hohe Anstrengung",
          "Mangelnde Anstrengung",
          "Schwierige Aufgabenstellung",
          "Pech"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "'Du hast sehr sorgfältig gearbeitet.'",
        correctAnswer: "Hohe Anstrengung",
        answers: [
          "Hohe Fähigkeiten",
          "Hohe Anstrengung",
          "Mangelnde Anstrengung",
          "Schwierige Aufgabenstellung",
          "Pech"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "'Auf für schwierige Textaufgaben hast du die notwendigen Fähigkeiten.'",
        correctAnswer: "Hohe Fähigkeiten",
        answers: [
          "Hohe Fähigkeiten",
          "Hohe Anstrengung",
          "Mangelnde Anstrengung",
          "Schwierige Aufgabenstellung",
          "Pech"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "'Kopf hoch, das war einfach nicht dein Tag.'",
        correctAnswer: "Pech",
        answers: [
          "Hohe Fähigkeiten",
          "Hohe Anstrengung",
          "Mangelnde Anstrengung",
          "Schwierige Aufgabenstellung",
          "Pech"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "'Wenn du das an deiner Bearbeitung änderst, kannst du Aufgaben besser lösen.'",
        correctAnswer: "Mangelnde Anstrengung",
        answers: [
          "Hohe Fähigkeiten",
          "Hohe Anstrengung",
          "Mangelnde Anstrengung",
          "Schwierige Aufgabenstellung",
          "Pech"
        ]),
  ],
  "Münchner Motivationstraining": [
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Beim Münchner Motivationstraining wird der {} Handlungsverlauf in den Fokus genommen.",
        correctAnswer: "komplette",
        answers: [
          "initiale",
          "komplette",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "SuS lernen dabei, Erfolge und Misserfolge {} zu {}.",
        correctAnswer: "funktional{}attribuieren",
        answers: []),
  ],
  "Training nach Rheinberg und Krug": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die SuS erhalten bei der Leistungsbewertung {} nach individueller Berzugsnorm.",
        correctAnswer: "Feedback",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die SuS können Aufgaben mit für sie passenden Schwierigkeitsanforderungen wählen. Dies ermöglicht {}.",
        correctAnswer: "Erfolgserlebnisse",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Es sollen {} Attributionen vermittelt werden.",
        correctAnswer: "realistische",
        answers: [
          "realistische",
          "gängige",
        ]),
  ],
};

List<LearningBite> trainingLearningBites = [
  LearningBite(
      name: "Reattributionstrainings",
      type: LearningBiteType.lesson,
      data: data["Reattributionstrainings"]!,
      iconData: FontAwesomeIcons.handsClapping,
      tasks: tasks["Reattributionstrainings"]!),
  LearningBite(
      name: "Münchner Motivationstraining",
      type: LearningBiteType.lesson,
      data: data["Münchner Motivationstraining"]!,
      iconData: FontAwesomeIcons.speakap,
      tasks: tasks["Münchner Motivationstraining"]!),
  LearningBite(
      name: "Training nach Rheinberg und Krug",
      type: LearningBiteType.lesson,
      data: data["Training nach Rheinberg und Krug"]!,
      iconData: FontAwesomeIcons.dumbbell,
      tasks: tasks["Training nach Rheinberg und Krug"]!),
];
