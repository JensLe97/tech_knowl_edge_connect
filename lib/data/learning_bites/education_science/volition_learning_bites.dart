import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Prozesse der Selbstregulation": [
    Column(
      children: [
        const Text("""
Volition (Willenskraft) bezieht sich auf die Umsetzung von Absichten in Handlungen und die willentliche Steuerung.\n
Sie befasst sich mit der Selbstregulation, wodurch die Ausführung der Handlung initiiert und bis zum Ende eines Ziels aufrechterhalten wird.
        """),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Attributionale Prozesse": [
    Column(
      children: [
        const Text("""
Attribution ist die Ursachenzuschreibung für ein Handlungsergebnis.\n
Dies können z.B. Anstrengung oder die Hilfe von anderen sein.
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
  "Prozesse der Selbstregulation": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Unterschieden wird zwischen Prozessen der {} und der {}.",
        correctAnswer: "Selbstkontrolle{}Planung",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Umfasst Prozesse, bei der eine Absicht gegen konkurrierende Ziele, Impulse, Bedürfnisse und Wünsche abgeschirmt wird.",
        correctAnswer: "Selbstkontrolle",
        answers: ["Selbstkontrolle", "Planung"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Disposition (deutsch: Aufteilung, Zuweisung) bedeutet in diesem Fall: {}.",
        correctAnswer: "Verhaltensbereitschaft",
        answers: ["Verhaltensbereitschaft", "Bedarfsermittlung"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Abschirmen einer Absicht gegebüber konkurrierenden Impulsen, z.B. Essen während den HAs: {}.",
        correctAnswer: "Handlungsorientierung",
        answers: ["Handlungsorientierung", "Lageorientierung"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Aufmerksamkeit verstärkt auf vergangene oder zukünftige Zustände fokussieren, z.B. Ziele und Alternativen bewerten: {}.",
        correctAnswer: "Lageorientierung",
        answers: ["Handlungsorientierung", "Lageorientierung"]),
  ],
  "Attributionale Prozesse": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Attributionen sind {}, die Individuen zur {} von Ereignissen, Handlungen und Erlebnissen in verschiedenen Lebensbereichen heranziehen.",
        correctAnswer: "Ursachen{}Erklärung",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Der Ursachenfaktor liegt innerhalb oder außerhalb der Person: {}.",
        correctAnswer: "Lokation oder Internalität",
        answers: [
          "Kontrollierbarkeit",
          "Stabilität",
          "Lokation oder Internalität"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Der Ursachenfaktor liegt zeitlich stabil oder variabel: {}.",
        correctAnswer: "Stabilität",
        answers: [
          "Kontrollierbarkeit",
          "Stabilität",
          "Lokation oder Internalität"
        ]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Der Ursachenfaktor ist durch eigenes Handeln kontrollierbar (Anstrengung vs. Zufall): {}.",
        correctAnswer: "Kontrollierbarkeit",
        answers: [
          "Kontrollierbarkeit",
          "Stabilität",
          "Lokation oder Internalität"
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Fähigkeit, Begabung.",
        correctAnswer: "Internal",
        answers: ["Internal", "External"]),
    Task(
        type: TaskType.singleChoice,
        question: "Fähigkeit, Begabung.",
        correctAnswer: "Unkontrollierbar",
        answers: ["Kontrollierbar", "Unkontrollierbar"]),
    Task(
        type: TaskType.singleChoice,
        question: "Fähigkeit, Begabung.",
        correctAnswer: "Stabil",
        answers: ["Stabil", "Variabel"]),
    Task(
        type: TaskType.singleChoice,
        question: "Hilfe anderer.",
        correctAnswer: "External",
        answers: ["Internal", "External"]),
    Task(
        type: TaskType.singleChoice,
        question: "Hilfe anderer.",
        correctAnswer: "Kontrollierbar",
        answers: ["Kontrollierbar", "Unkontrollierbar"]),
    Task(
        type: TaskType.singleChoice,
        question: "Hilfe anderer.",
        correctAnswer: "Variabel",
        answers: ["Stabil", "Variabel"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Erfolge werden eher dem Zufall zugeschrieben und nicht auf eigene Fähigkeiten: {}.",
        correctAnswer: "niedriges Fähigkeitsselbstkonzept",
        answers: [
          "hohes Fähigkeitsselbstkonzept",
          "niedriges Fähigkeitsselbstkonzept"
        ]),
  ],
};

List<LearningBite> volationLearningBites = [
  LearningBite(
      name: "Prozesse der Selbstregulation",
      type: LearningBiteType.lesson,
      data: data["Prozesse der Selbstregulation"]!,
      iconData: FontAwesomeIcons.scaleBalanced,
      tasks: tasks["Prozesse der Selbstregulation"]!),
  LearningBite(
      name: "Attributionale Prozesse",
      type: LearningBiteType.lesson,
      data: data["Attributionale Prozesse"]!,
      iconData: FontAwesomeIcons.listCheck,
      tasks: tasks["Attributionale Prozesse"]!),
];
