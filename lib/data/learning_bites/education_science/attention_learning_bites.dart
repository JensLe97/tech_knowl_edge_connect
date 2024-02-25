import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Ressourcenverbrauch": [
    Column(
      children: [
        const Text("""
Die Verarbeitung von Informationen findet in einem kapazitätsbegrenzten System statt.\n
Es müssen Mechanismen angenommen werden, die aufgabenbezogene Selektionsprozesse (Aufmerksamkeit) leisten können.
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
  "Ressourcenverbrauch": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Lernen ein ressourcenbeanspruchender Prozess des Aufbaus menatler Konstruktionen. Dieser Ressourcenverbrauch ist in der {} theory beschrieben",
        correctAnswer: "cognitive load",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nRessourcenbeanspruchung aus der Komplexität (element interactivity) des Lernstoffs",
        correctAnswer: "intrisic cognitive load",
        answers: [
          "intrisic cognitive load",
          "extraneous cognitive load",
          "germane cognitive load",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nRessourcenbeanspruchung aus der Art, wie der Sachverhalt dem Lernenden angeboten wird",
        correctAnswer: "extraneous cognitive load",
        answers: [
          "intrisic cognitive load",
          "extraneous cognitive load",
          "germane cognitive load",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne zu:\nRessourcenbeanspruchung, die für den Lernprozess notwendig ist, um das Lernmaterial zu verstehen",
        correctAnswer: "germane cognitive load",
        answers: [
          "intrisic cognitive load",
          "extraneous cognitive load",
          "germane cognitive load",
        ]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Wenn die Menge der benötigten Ressourcen, das Ausmaß der verfügbaren Kapatität (cognitive capacity) übersteigen, spricht man von {}.",
        correctAnswer: "cognitive overload",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Es sollte auf {}, irrelevante Dinge verzichtet werden, um Ressourcen zu sparen.",
        correctAnswer: "lernunwichtige",
        answers: ["wichtige", "lernunwichtige"]),
  ],
};

List<LearningBite> attentionStrategiesLearningBites = [
  LearningBite(
      name: "Ressourcenverbrauch",
      type: LearningBiteType.lesson,
      data: data["Ressourcenverbrauch"]!,
      iconData: FontAwesomeIcons.batteryQuarter,
      tasks: tasks["Ressourcenverbrauch"]!),
];
