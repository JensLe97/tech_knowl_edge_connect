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
In der Selbstbestimmungstheorie der Motivation nach Deci & Ryan werden Beweggründe für das Handeln dargestellt.\n
Hier spielen wertbezogene Aspekte eine Rolle, also die Bedeutsamkeit des Erreichens eines bestimmten Zustandes.
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
  "Überwachung": [
    Column(
      children: [
        const Text("""
Eccles (2000) unterscheidet zwischen verschiedenen Werten einer Handlung:\n
    1. Intrinsischer Wert
    2. Nützlichkeit
    3. Persönlische Wichtigkeit
    4. Kosten
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
Ziele sind Vorwegnahmen von Handlungsfolgen, die sich auf zukünftige, angestrebte Handlungsergebnisse beziehen.\n
Sie geben dem Handeln eine Richtung und stellen einen Maßstab zur Überwachung des Fortschrittes bereit.
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Bewertung": [
    Column(
      children: [
        const Text("""
Eccles (2000) unterscheidet zwischen verschiedenen Werten einer Handlung:\n
    1. Intrinsischer Wert
    2. Nützlichkeit
    3. Persönlische Wichtigkeit
    4. Kosten
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
  "Planung": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Speist sich aus den antizipierten Konsequenzen einer Handlung.",
        correctAnswer: "Extrinsische Motivation",
        answers: [
          "Extrinsische Motivation",
          "Intrinsische Motivation",
          "Amotivation"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Stellt einen nicht zielgerichteten Antrieb für Handlungen dar.",
        correctAnswer: "Amotivation",
        answers: [
          "Extrinsische Motivation",
          "Intrinsische Motivation",
          "Amotivation"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Beruht auf der Antizipation einer als befriedigend oder positiv erlebten Ausführung einer Handlung.",
        correctAnswer: "Intrinsische Motivation",
        answers: [
          "Extrinsische Motivation",
          "Intrinsische Motivation",
          "Amotivation"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Personen lernen, wenn die Konsequenzen einer Handlung für sie persönlich bedeutsam sind: {}-extrinsisch.",
        correctAnswer: "Selbstbestimmt",
        answers: ["Selbstbestimmt", "Fremdbestimmt"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Der Beweggrund liegt in externalen Belohnungen, Sanktionen, Regeln oder Normen: {}-extrinsisch.",
        correctAnswer: "Fremdbestimmt",
        answers: ["Selbstbestimmt", "Fremdbestimmt"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Studien zeigen, dass {} motivierte Lerner bessere Lernstrategien verwenden.",
        correctAnswer: "intrinsisch",
        answers: ["intrinsisch", "extrinsisch"]),
  ],
  "Überwachung": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Bei der Nützlichkeit geht es vor allem um {} Motivation.",
        correctAnswer: "Fremdbestimmt-extrinsiche",
        answers: [
          "intrinsische",
          "Selbstbestimmt-extrinsiche",
          "Fremdbestimmt-extrinsiche"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Bei der persönlichen Wichtigkeit geht es vor allem um {} Motivation.",
        correctAnswer: "Selbstbestimmt-extrinsiche",
        answers: [
          "intrinsische",
          "Selbstbestimmt-extrinsiche",
          "Fremdbestimmt-extrinsiche"
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Kosten umfassen die die Begrenzung der Möglichkeiten, eine {} Handlung auszuführen.",
        correctAnswer: "alternative",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Zudem gehören dazu die notwendige {} und {} Kosten.",
        correctAnswer: "Anstrengung{}emotionale",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die vorübergehend emotitionale Erregung und Aufmerksamkeit beim Lernen aufgrund von Interesanntheit nennt man {}.",
        correctAnswer: "situatives Interesse",
        answers: []),
  ],
  "Regulation": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Man unterscheidet zwischen{}-, {}- und {}zielen.",
        correctAnswer: "Lern{}Performanz{}Arbeitsvermeidungs",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Schlechte Leistungen vermeiden und Kompetenzdefizite verbergen",
        correctAnswer: "Vermeidungsperformanzziel",
        answers: [
          "Annäherungslernziel",
          "Vermeidungslernziel",
          "Annäherungsperformanzziel",
          "Vermeidungsperformanzziel",
          "Arbeitsvermeidungsziel"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Geringen Lernzuwachs oder falsches Verständnis vermeiden",
        correctAnswer: "Vermeidungslernziel",
        answers: [
          "Annäherungslernziel",
          "Vermeidungslernziel",
          "Annäherungsperformanzziel",
          "Vermeidungsperformanzziel",
          "Arbeitsvermeidungsziel"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Eigene Kompetenzen erweitern und Verständnis erlangen",
        correctAnswer: "Annäherungslernziel",
        answers: [
          "Annäherungslernziel",
          "Vermeidungslernziel",
          "Annäherungsperformanzziel",
          "Vermeidungsperformanzziel",
          "Arbeitsvermeidungsziel"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Vorgegebene Anforderungen mit möglichst wenig Aufwand erfüllen",
        correctAnswer: "Arbeitsvermeidungsziel",
        answers: [
          "Annäherungslernziel",
          "Vermeidungslernziel",
          "Annäherungsperformanzziel",
          "Vermeidungsperformanzziel",
          "Arbeitsvermeidungsziel"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Gute Leistungen zeigen und eigene Kompetenzen demonstrieren",
        correctAnswer: "Annäherungsperformanzziel",
        answers: [
          "Annäherungslernziel",
          "Vermeidungslernziel",
          "Annäherungsperformanzziel",
          "Vermeidungsperformanzziel",
          "Arbeitsvermeidungsziel"
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Relevanz von Bezugspersonen für die Wertkomponente nennt man auch {}.",
        correctAnswer: "Sozialisationseffekt",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die Wertkomponente ist beeinflusst durch Motive, Bedürfnisse, Zielorientierungen und personales Interesse und steht in Zusammenhang mit kontextuellen Mermalen wie der {}.",
        correctAnswer: "Klassenzielstruktur",
        answers: []),
  ],
  "Bewertung": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Bei der Nützlichkeit geht es vor allem um {} Motivation.",
        correctAnswer: "Fremdbestimmt-extrinsiche",
        answers: [
          "intrinsische",
          "Selbstbestimmt-extrinsiche",
          "Fremdbestimmt-extrinsiche"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Bei der persönlichen Wichtigkeit geht es vor allem um {} Motivation.",
        correctAnswer: "Selbstbestimmt-extrinsiche",
        answers: [
          "intrinsische",
          "Selbstbestimmt-extrinsiche",
          "Fremdbestimmt-extrinsiche"
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Kosten umfassen die die Begrenzung der Möglichkeiten, eine {} Handlung auszuführen.",
        correctAnswer: "alternative",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Zudem gehören dazu die notwendige {} und {} Kosten.",
        correctAnswer: "Anstrengung{}emotionale",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Die vorübergehend emotitionale Erregung und Aufmerksamkeit beim Lernen aufgrund von Interesanntheit nennt man {}.",
        correctAnswer: "situatives Interesse",
        answers: []),
  ],
};

List<LearningBite> metacognitiveLearningBites = [
  LearningBite(
      name: "Planung",
      type: LearningBiteType.lesson,
      data: data["Planung"]!,
      iconData: FontAwesomeIcons.chessBoard,
      tasks: tasks["Planung"]!),
  LearningBite(
      name: "Überwachung",
      type: LearningBiteType.lesson,
      data: data["Überwachung"]!,
      iconData: FontAwesomeIcons.award,
      tasks: tasks["Überwachung"]!),
  LearningBite(
      name: "Regulation",
      type: LearningBiteType.lesson,
      data: data["Regulation"]!,
      iconData: FontAwesomeIcons.rocket,
      tasks: tasks["Regulation"]!),
  LearningBite(
      name: "Bewertung",
      type: LearningBiteType.lesson,
      data: data["Bewertung"]!,
      iconData: FontAwesomeIcons.rocket,
      tasks: tasks["Bewertung"]!),
];
