import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Fragenstellen": [
    Column(
      children: [
        const Text("""
Es gibt Schüler- und Lehrerfragen.\n
Fragenstellen fördert...\n
    1. die Konstruktion von Wissen
    2. die lernorientierte Motivation
    3. metakognitive Fertigkeiten
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Notizenmachen": [
    Column(
      children: [
        const Text("""
Allein das Anfertigen von Notizen verbessert die Behaltensleistung.\nEs verstärkt die Aufmerksamkeit, verbessert die Elaboration der Inhalte und vertieft die Strukturierung.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Vorstellungsbilder": [
    Column(
      children: [
        const Text("""
Menschen können visuelle Vorstellungen erstellen und der Einsatz von Vorstellungsbildern wird als Imagery-Strategie bezeichnet.\n
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Mnemotechniken": [
    Column(
      children: [
        const Text("""
Mnemotechnik steht als Bezeichnung für die Nutzung sachfremder Lern- und Gedächtnishilfen zur leichteren Einprägung unterschiedlicher Lerninhalte.\n
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Wiederholungsstrategien": [
    Column(
      children: [
        const Text("""
Wiederholungsstrategien beinhalten repetitive Prozesse, die aus das Einprägen oberflächlicher Merkmale ausgerichtet sind.\n
Es sind Oberflächenstrategien.
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
  "Fragenstellen": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Fragen, die keinen sozialen Kontakt voraussetzen werden {} genannt.",
        correctAnswer: "Selbstfragen",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Fragen, die an mögliche Beantworte gestellt werden, werden {} genannt.",
        correctAnswer: "kommunikative Fragen",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die Erkenntnisse und das Wissen das aus Fragenstellen generiert wird, ist teil welcher Theorie?",
        correctAnswer: "Epistemologie",
        answers: [
          "Empirismus",
          "Epistemologie",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die 3 Teilprozesse beim Fragenstellen sind:\n  1. Feststellung einer {}\n  2. sprachliche {} als Frage\n  3. Soziale Bearbeitung ({})",
        correctAnswer: "Anomalie{}Artikulierung{}editing",
        answers: []),
  ],
  "Notizenmachen": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Das Anfertigen von Notizen kann zu zusätzlichen {}, Schlussfolgerungen und Interpretationen führen.",
        correctAnswer: "Assoziationen",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Für den Lernerfolg ist die {} von Notizen sehr bedeutend.",
        correctAnswer: "Vollständigkeit",
        answers: ["Ausführlichkeit", "Vollständigkeit"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Der Gesamtzusammenhang ist erst verstanden, wenn ein {} erzeugt werden kann (Wiedergabe in eigenen Worten).",
        correctAnswer: "Situationsmodell",
        answers: ["Situationsmodell", "Personenmodell"]),
  ],
  "Vorstellungsbilder": [
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Die Anreicherung durch weitere Informationen aus dem Gedächtnis wird als {} bezeichnet.",
        correctAnswer: "Elaboration",
        answers: ["Elaboration", "Regulation", "Reproduktion"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Mentale Konstruktion von Objekten und Situationen aufgrund von bereits vorhandenem Wissen, wird als '{}' bezeichnet.",
        correctAnswer: "mental imagery",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne die Vorstellungsbilder zu:\nVisuell",
        correctAnswer: "Modalitätsspezifisch",
        answers: [
          "Modalitätsunspezifisch",
          "Modalitätsspezifisch",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne die Vorstellungsbilder zu:\nRäumlich",
        correctAnswer: "Modalitätsunspezifisch",
        answers: [
          "Modalitätsunspezifisch",
          "Modalitätsspezifisch",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Kindern im Grundschulalter werden Illustrationen zusätzlich zum Text vorgelegt. Dies wird auch '{}' genannt",
        correctAnswer: "imposed imagery strategy",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Eine wirksame Imagery-Fördermaßnahme, bei der das Lesen eines Textes systematisch durch Aktivitäten gesteuert wird, heißt '{}'.",
        correctAnswer: "reciprocal teaching",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Aktivitäten werden ausgehend von einer Orientierungsvorlage ({}) vom Lehrer vorgemacht ({}).",
        correctAnswer: "scaffolding{}modelling",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Im Rotationsverfahren werden die Aktivitäten von den Lernenden praktiziert, wobei der Lehrer helfend eingreift ({}), um dann seine Hilfe immer mehr zu reduzieren ({}).",
        correctAnswer: "coaching{}fading out",
        answers: []),
  ],
  "Mnemotechniken": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Es geht um die Schaffung eines {} Systems, indem Erinnerungen in Form von Gedächtnisbildern an {} Orten abgelegt werden.",
        correctAnswer: "memorialen{}imaginären",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Durch diese Strategie soll die Begrenzung des {} umgangen werden.",
        correctAnswer: "Kurzzeitgedächtnisses",
        answers: ["Kurzzeitgedächtnisses", "Langzeitgedächtnisses"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Es soll ein stabiles Netz aus {} Kognitionen, die mit dem Lernmaterial verknüpft sind, erlernt werden.",
        correctAnswer: "organisierten",
        answers: ["organisierten", "unstrukturierten"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Beispiele sind {}, Chunking, Bilderketten bilden, {} und {}.",
        correctAnswer: "Clustering{}Mindmaps{}Eselsbrücken",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Morris (1978) unterscheidet:\nBasieren ausschließlich auf Besonderheiten der gedächtnismäßigen Informationsverarbeitung.",
        correctAnswer: "interne Gedächtnishilfen",
        answers: ["externe Gedächtnishilfen", "interne Gedächtnishilfen"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Morris (1978) unterscheidet:\nAußerhalb der Person liegende Mittel wie Kalender und Notizbücher.",
        correctAnswer: "externe Gedächtnishilfen",
        answers: ["externe Gedächtnishilfen", "interne Gedächtnishilfen"]),
  ],
  "Wiederholungsstrategien": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Mit Ausnahme von '{}' (Man fasst nicht zweimal aus die Herdplatte) oder das Erlernen einer {}, ist jegliches Lernen mit Wiederholung verbunden.",
        correctAnswer: "one trial learning{}Einsicht",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Information wird im Arbeitsgedächtnis aufrechterhalten: {}.",
        correctAnswer: "maintaining rehearsal",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Jemand sagt sich gedanklich immer wieder eine Telefonnummer vor.",
        correctAnswer: "Innerliches Wiederholen",
        answers: ["Innerliches Wiederholen", "Äußerliches Wiederholen"]),
    Task(
        type: TaskType.singleChoice,
        question: "Wiederholungen werden laut oder halblaut aufgesagt.",
        correctAnswer: "Äußerliches Wiederholen",
        answers: ["Innerliches Wiederholen", "Äußerliches Wiederholen"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Schwierige Fachbegriffe müssen mehrfach enkodiert werden (Lesen: visuell, Hören: klanglich). Dies nennt man {}.",
        correctAnswer: "Wiederholtes encoding",
        answers: ["Wiederholtes encoding", "Wiederholtes retrieval"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Abrufwege müssen gezielt gebahnt werden, um Informationen jederzeit verfügbar (available) und zugänglich (accessible) zu halten. Dies nennt man {}.",
        correctAnswer: "wiederholtes encoding",
        answers: ["wiederholtes encoding", "wiederholtes retrieval"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Anzahl, Tempo, {} und Dichte von Wiederholungen richten sich nach den aktuellen {} und psychischen Möglichkeiten, Art und {} und nach der Zielsetzung.",
        correctAnswer: "Dauer{}physischen{}Umfang",
        answers: []),
  ],
};

List<LearningBite> elaborationStrategiesLearningBites = [
  LearningBite(
      name: "Fragenstellen",
      type: LearningBiteType.lesson,
      data: data["Fragenstellen"]!,
      iconData: FontAwesomeIcons.question,
      tasks: tasks["Fragenstellen"]!),
  LearningBite(
      name: "Notizenmachen",
      type: LearningBiteType.lesson,
      data: data["Notizenmachen"]!,
      iconData: FontAwesomeIcons.noteSticky,
      tasks: tasks["Notizenmachen"]!),
  LearningBite(
      name: "Vorstellungsbilder",
      type: LearningBiteType.lesson,
      data: data["Vorstellungsbilder"]!,
      iconData: FontAwesomeIcons.image,
      tasks: tasks["Vorstellungsbilder"]!),
  LearningBite(
      name: "Mnemotechniken",
      type: LearningBiteType.lesson,
      data: data["Mnemotechniken"]!,
      iconData: FontAwesomeIcons.building,
      tasks: tasks["Mnemotechniken"]!),
  LearningBite(
      name: "Wiederholungsstrategien",
      type: LearningBiteType.lesson,
      data: data["Wiederholungsstrategien"]!,
      iconData: FontAwesomeIcons.repeat,
      tasks: tasks["Wiederholungsstrategien"]!),
];
