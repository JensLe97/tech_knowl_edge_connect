import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Elaborationsstrategien": [
    Column(
      children: [
        const Text("""
Elaborationsstrategien dienen dem Verstehen und darhaften Behalten neuer Informationen.\n
Dazu zählen:
    1. Vorwissen aktivieren
    2. Fragenstellen
    3. Notizenmachen
    4. Vorstellungsbilder generieren
    5. Mnemotechniken
    6. Wiederholungsstrategien
        """),
        SizedBox(
          height: 200,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Organisationsstrategien": [
    Column(
      children: [
        const Text("""
Organisationsstrategien organisieren neues Wissen und strukturien es, indem die zwischen Wissenselementen bestehenden Verknüpfungen herausgearbeitet werden.\n
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Selbstregulationsstrategien": [
    Column(
      children: [
        const Text("""
Diese Strategien dienen der situations- und aufgabenangemessenen Steuerung des Lernprozesses vor allem der...\n
    1. Planung 
    2. Überwachung 
    3. Bewertung
    4. Regulation
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Wissensnutzungsstrategien": [
    Column(
      children: [
        const Text("""
Diese Strategien soll 'träges Wissen' vorbeugen, also Wissen, welches in Anwendungs- und Transferaufgaben nicht aktiviert werden kann.\n
Es sollten bereits in der Lernphase Aufgaben gestellt werden, die Anwendung und Transfer erfordern.
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
  "Elaborationsstrategien": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Elaborationsstrategien wollen neue Informationen in bestehende {} (Vorstellungsbilder, Vorwissen) integrieren.",
        correctAnswer: "Wissensstrukturen",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Welche drei Gedächtnisspuren müssen gespeichert werden, damit man sich an den Sinn, Wortlaut und die Situation erinnert?\nMentale Repräsentationen...\nvon der {} (z.B. exakter Wortlaut)\nvon der {} ('Sinngemäß stand da...')\nvom {} (z.B. Tag an dem es behandelt wurde)",
        correctAnswer: "Oberfläche{}Bedeutung{}Kontext",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Es wird an bestehende kognitive Strukturen 'angedockt', um Andockstellen für neues Wissen zu ermöglichen.",
        correctAnswer: "Aktivieren von Vorwissen",
        answers: [
          "Aktivieren von Vorwissen",
          "Fragenstellen",
          "Notizenmachen",
          "Vorstellungsbilder",
          "Mnemotechniken",
          "Wiederholungsstrategien",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Dient der Aufmerksamkeitssteuerung und der elaborativen Verarbeitung.",
        correctAnswer: "Fragenstellen",
        answers: [
          "Aktivieren von Vorwissen",
          "Fragenstellen",
          "Notizenmachen",
          "Vorstellungsbilder",
          "Mnemotechniken",
          "Wiederholungsstrategien",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ist eine multifunktionale Strategie (elaborative und strak strukturiend-organisatorische Elemente).",
        correctAnswer: "Notizenmachen",
        answers: [
          "Aktivieren von Vorwissen",
          "Fragenstellen",
          "Notizenmachen",
          "Vorstellungsbilder",
          "Mnemotechniken",
          "Wiederholungsstrategien",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Lösen im Arbeitsgedächtnis zusätzliche Verarbeitungsprozesse aus, sodass Verknüpfungen hergestellt werden können.",
        correctAnswer: "Vorstellungsbilder",
        answers: [
          "Aktivieren von Vorwissen",
          "Fragenstellen",
          "Notizenmachen",
          "Vorstellungsbilder",
          "Mnemotechniken",
          "Wiederholungsstrategien",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Müssen erlernt werden.",
        correctAnswer: "Mnemotechniken",
        answers: [
          "Aktivieren von Vorwissen",
          "Fragenstellen",
          "Notizenmachen",
          "Vorstellungsbilder",
          "Mnemotechniken",
          "Wiederholungsstrategien",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Sind sehr wichtig im Lernprozess, denn sie sind Enkodierstrategien.",
        correctAnswer: "Wiederholungsstrategien",
        answers: [
          "Aktivieren von Vorwissen",
          "Fragenstellen",
          "Notizenmachen",
          "Vorstellungsbilder",
          "Mnemotechniken",
          "Wiederholungsstrategien",
        ]),
  ],
  "Organisationsstrategien": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Bei Organisationsstrategien wird die Fülle des Stoffes auf das Wesentliche reduziert.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Sogenannte {} unterstützen das Verstehen, indem neue Informationen in vorhandene, gut ausgebildete Wissensstrukturen integriert werden.",
        correctAnswer: "Wissensschemata",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Organisationsstrategien sind Abrufhilfen, welche das {} anregen.",
        correctAnswer: "Langzeitgedächtnis",
        answers: [
          "Kurzzeitgedächtnis",
          "Langzeitgedächtnis",
        ]),
  ],
  "Selbstregulationsstrategien": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Ordne zu:\nDamit bin ich noch nicht zufrieden",
        correctAnswer: "Bewertung",
        answers: [
          "Planung",
          "Überwachung",
          "Bewertung",
          "Regulation",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Ordne zu:\nWie gehe ich bei dieser Aufgabe vor?",
        correctAnswer: "Planung",
        answers: [
          "Planung",
          "Überwachung",
          "Bewertung",
          "Regulation",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Ordne zu:\nDas muss ich nochmal lesen",
        correctAnswer: "Regulation",
        answers: [
          "Planung",
          "Überwachung",
          "Bewertung",
          "Regulation",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Ordne zu:\nHabe ich das wirklich verstanden",
        correctAnswer: "Überwachung",
        answers: [
          "Planung",
          "Überwachung",
          "Bewertung",
          "Regulation",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Es sind metagognitive Strategien, weil sie eine {} Komponente haben (Nachdenken über das Nachdenken)",
        correctAnswer: "selbstreflexive",
        answers: []),
  ],
  "Wissensnutzungsstrategien": [
    Task(
        type: TaskType.singleChoice,
        question: "Was ist keine transferangemessene Verarbeitungsstrategie:",
        correctAnswer: "Schreiben von Karteikarten",
        answers: [
          "Lösen von Problemen",
          "Schreiben von Texten",
          "Schreiben von Karteikarten",
          "Argumentieren/Diskutieren im sozialen Kontext"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "In diesen Situation muss wissen aus dem {} abgerufen werden.",
        correctAnswer: "Langzeitgedächtnis",
        answers: [
          "Kurzeitgedächtnis",
          "Arbeitsgedächtnis",
          "Langzeitgedächtnis"
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Es wird unterschiedn zwischen 'Schreiben als Wiedergabe von Wissen' und 'Schreiben als {}'.",
        correctAnswer: "Wissenstransformation",
        answers: []),
  ],
};

List<LearningBite> advancedStrategiesLearningBites = [
  LearningBite(
      name: "Elaborationsstrategien",
      type: LearningBiteType.lesson,
      data: data["Elaborationsstrategien"]!,
      iconData: FontAwesomeIcons.plus,
      tasks: tasks["Elaborationsstrategien"]!),
  LearningBite(
      name: "Organisationsstrategien",
      type: LearningBiteType.lesson,
      data: data["Organisationsstrategien"]!,
      iconData: FontAwesomeIcons.sort,
      tasks: tasks["Organisationsstrategien"]!),
  LearningBite(
      name: "Selbstregulationsstrategien",
      type: LearningBiteType.lesson,
      data: data["Selbstregulationsstrategien"]!,
      iconData: FontAwesomeIcons.scaleBalanced,
      tasks: tasks["Selbstregulationsstrategien"]!),
  LearningBite(
      name: "Wissensnutzungsstrategien",
      type: LearningBiteType.lesson,
      data: data["Wissensnutzungsstrategien"]!,
      iconData: FontAwesomeIcons.toolbox,
      tasks: tasks["Wissensnutzungsstrategien"]!),
];
