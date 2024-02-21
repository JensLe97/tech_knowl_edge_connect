import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Wert- und Erfolgserwartung": [
    Column(
      children: [
        const Text("""
Mit der Herstellung von situativem Interesse lässt sich die Erfolgserwartung und der Wert der Lernhandlung erhöhen.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Motivation und Interesse": [
    Column(
      children: [
        const Text("""
Nach der Selbstbestimmungstheorie der Motivation sollen bestimmte motivationale Grundbedürfnisse nach\n
    - Autonomie
    - Kompetenzerleben und
    - sozialer Eingebundenheit
gefördert werden.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Ziele setzen": [
    Column(
      children: [
        const Text("""
Ziele setzen und eine motivations- und lernförderliche Zielstruktur im Unterricht herstellen, funktioniert besonders gut wenn diese SMART formuliert werden.\n
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
  "Wert- und Erfolgserwartung": [
    Task(
        type: TaskType.singleChoice,
        question: "Betonung der Bedeutsamkeit des Lerngegenstandes",
        correctAnswer: "Förderung von Wert",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Artikulierung des eigenen Interesses an den Lerninhalten",
        correctAnswer: "Förderung von Wert",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "An ähnliche, bereits bewältigte Aufgaben erinnern",
        correctAnswer: "Förderung von Erfolgserwartung",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Herstellung von praktischen Anwendungsmöglichkeiten und Alltagsbezügen",
        correctAnswer: "Förderung von Wert",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Lehrziele und passende Lehrmethodik einer Unterrichtseinheit verdeutlichen",
        correctAnswer: "Förderung von Erfolgserwartung",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Aufgabenstellungen klar verständlich kommunizieren",
        correctAnswer: "Förderung von Erfolgserwartung",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Induzieren kognitiver Konflikte (Widersprüche zum vorhandenen Wissen)",
        correctAnswer: "Förderung von Wert",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Herangehensweisen und Lösungsschritte bewusst machen",
        correctAnswer: "Förderung von Erfolgserwartung",
        answers: [
          "Förderung von Erfolgserwartung",
          "Förderung von Wert",
        ]),
  ],
  "Motivation und Interesse": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Selbstbestimmungstheorie der Motivation besagt, dass die Erfüllung der Bedürfnisse nach {}, {} und {} intrinsische Motivation und Interesse begünstigt.",
        correctAnswer: "Autonomie{}Kompetenzerleben{}sozialer Eingebundenheit",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question: "Einsatz von Gruppenarbeitsmethoden.",
        correctAnswer: "Soziale Eingebundenheit",
        answers: [
          "Autonomie",
          "Kompetenzerleben",
          "Soziale Eingebundenheit",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Gemeinsames Aushandeln von Verhaltensregeln.",
        correctAnswer: "Autonomie",
        answers: [
          "Autonomie",
          "Kompetenzerleben",
          "Soziale Eingebundenheit",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Klare, verhaltensorientierte Rückmeldung zu Erfolgen und Unterstützung bei Schwierigkeiten.",
        correctAnswer: "Kompetenzerleben",
        answers: [
          "Autonomie",
          "Kompetenzerleben",
          "Soziale Eingebundenheit",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Mitbestimmungsmöglichkeiten bei Lernzielen, Lerngegenständen und Lernwegen.",
        correctAnswer: "Autonomie",
        answers: [
          "Autonomie",
          "Kompetenzerleben",
          "Soziale Eingebundenheit",
        ]),
  ],
  "Ziele setzen": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Kriterium wird am meisten angesprochen?\n'Heute Abend wiederhole ich die Vokabeln aus Kapitel 3, bis ich alle Vokabeln kann.'",
        correctAnswer: "Anspruchsvoll",
        answers: [
          "Spezifisch",
          "Messbar",
          "Anspruchsvoll",
          "Realistisch",
          "Terminiert"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Kriterium wird am meisten angesprochen?\n'Heute Abend wiederhole ich die Vokabeln aus Kapitel 3.'",
        correctAnswer: "Spezifisch",
        answers: [
          "Spezifisch",
          "Messbar",
          "Anspruchsvoll",
          "Realistisch",
          "Terminiert"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Kriterium wird am meisten angesprochen?\n'Heute Abend wiederhole ich die Vokabeln aus Kapitel 3, bis ich maximal 3 Vokabeln nicht kann und zwar direkt nach den Hausaufgaben.'",
        correctAnswer: "Terminiert",
        answers: [
          "Spezifisch",
          "Messbar",
          "Anspruchsvoll",
          "Realistisch",
          "Terminiert"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Kriterium wird am meisten angesprochen?\n'Heute Abend wiederhole ich die Vokabeln aus Kapitel 3, bis ich eine bestimmte Anzahl an Vokabeln kann.'",
        correctAnswer: "Messbar",
        answers: [
          "Spezifisch",
          "Messbar",
          "Anspruchsvoll",
          "Realistisch",
          "Terminiert"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Kriterium wird am meisten angesprochen?\n'Heute Abend wiederhole ich die Vokabeln aus Kapitel 3, bis ich maximal 3 Vokabeln kann.'",
        correctAnswer: "Realistisch",
        answers: [
          "Spezifisch",
          "Messbar",
          "Anspruchsvoll",
          "Realistisch",
          "Terminiert"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Gewährung von ausreichender Bearbeitungszeit und Ausrichtung an leistugsschwächeren SuS",
        correctAnswer: "Timing",
        answers: ["Task", "Authority", "Recognition", "Evaluation", "Timing"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Verwendung von individuellen und kriterialen Bezugsnormen bei der Aufgabenbewertung",
        correctAnswer: "Evaluation",
        answers: ["Task", "Authority", "Recognition", "Evaluation", "Timing"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Entwicklungsangemessene Übertragung der Verantwortung für das Lernen und die Zusammenarbeit",
        correctAnswer: "Authority",
        answers: ["Task", "Authority", "Recognition", "Evaluation", "Timing"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Nutzung von abwechsungsreichen, vielfältigen, persönlich bedeutsamen, sinnhaften, emotionsreichen Aufgabenstellungen",
        correctAnswer: "Task",
        answers: ["Task", "Authority", "Recognition", "Evaluation", "Timing"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Anerkennung von Anstrengung durch Lob, positive emotionale Reaktionen und Belohnung",
        correctAnswer: "Recognition",
        answers: ["Task", "Authority", "Recognition", "Evaluation", "Timing"]),
  ],
};

List<LearningBite> supportLearningBites = [
  LearningBite(
      name: "Wert- und Erfolgserwartung",
      type: LearningBiteType.lesson,
      data: data["Wert- und Erfolgserwartung"]!,
      iconData: FontAwesomeIcons.lightbulb,
      tasks: tasks["Wert- und Erfolgserwartung"]!),
  LearningBite(
      name: "Motivation und Interesse",
      type: LearningBiteType.lesson,
      data: data["Motivation und Interesse"]!,
      iconData: FontAwesomeIcons.peopleCarryBox,
      tasks: tasks["Motivation und Interesse"]!),
  LearningBite(
      name: "Ziele setzen",
      type: LearningBiteType.lesson,
      data: data["Ziele setzen"]!,
      iconData: FontAwesomeIcons.arrowPointer,
      tasks: tasks["Ziele setzen"]!),
];
