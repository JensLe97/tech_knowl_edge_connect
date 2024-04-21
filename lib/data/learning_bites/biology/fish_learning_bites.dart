import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Allgemeine Merkmale": [
    Column(
      children: [
        const Text("""
Fische (Pisces) haben folgende Eigenschaften:\n
  1. Atmung über Kiemen (Gasaustausch)
  2. Aufbau des Skeletts aus Knochen oder Knorpel
  3. Haut mit Schuppen und Schleimdrüsen
  4. Eierlegend (ovipar) oder lebendgebärend (vivipar)
  5. Wechselwarm
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Anatomie": [
    Column(
      children: [
        const Text("""
Körperbau der Knochenfische
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/fish_side.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Körperbau der Knochenfische
  - Gonande (Geschlechtsdrüse)
  - Coelom (Raum für Herz und Verdauungssystem)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/fish_long.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Mithilfe der Schwimmblase können Fische im Wasser schweben indem Luft in die Blase gefüllt wird.\n
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/bubble.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Das Kreislaufsystem geschlossen und einfach im Gegensatz zu den zwei Lungen- und Körperkreisläufen bei Säugetieren.\n
        """),
        SizedBox(
          height: 200,
          child: Image.asset('images/learning_bites/biology/fish_circle.png'),
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 200,
          child: Image.asset('images/learning_bites/biology/mammals_cycle.png'),
        ),
      ],
    ),
  ],
};

Map<String, List<Task>> tasks = {
  "Allgemeine Merkmale": [
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Wenn die Eier des Weibchens im Körper befruchtet werden und in der Mutter heranwachsen, nennt man das {}.",
        correctAnswer: "ovulipar",
        answers: ["ovipar", "ovulipar", "ovovipar", "vivipar"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Wenn die Eier des Weibchens im Körper befruchtet werden und außerhalb der Mutter heranwachsen, nennt man das {}.",
        correctAnswer: "ovovipar",
        answers: ["ovipar", "ovulipar", "ovovipar", "vivipar"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Wenn die Eier des Weibchens außerhalb des Körpers befruchtet werden, nennt man das {}.",
        correctAnswer: "ovipar",
        answers: ["ovipar", "ovulipar", "ovovipar", "vivipar"]),
  ],
  "Anatomie": [
    Task(
        type: TaskType.singleChoice,
        question: "Welche Fische haben eine Schwimmblase?",
        correctAnswer: "Knochenfische",
        answers: ["Knochenfische", "Knorpelfische"]),
    Task(
        type: TaskType.singleChoice,
        question: "Welche Fische haben eine innere Befruchtung?",
        correctAnswer: "Knorpelfische",
        answers: ["Knochenfische", "Knorpelfische"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welche Fische haben Placoidschuppen (Hautzähnchen) im Gegensatz zu Knochenschuppen mit Schleimschicht?",
        correctAnswer: "Knorpelfische",
        answers: ["Knochenfische", "Knorpelfische"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Die Eier von Fischen nennt man {}.",
        correctAnswer: "Laich",
        answers: []),
  ],
};

List<LearningBite> fishLearningBites = [
  LearningBite(
      name: "Allgemeine Merkmale",
      type: LearningBiteType.lesson,
      data: data["Allgemeine Merkmale"]!,
      iconData: FontAwesomeIcons.fish,
      tasks: tasks["Allgemeine Merkmale"]!),
  LearningBite(
      name: "Anatomie",
      type: LearningBiteType.lesson,
      data: data["Anatomie"]!,
      iconData: FontAwesomeIcons.fishFins,
      tasks: tasks["Anatomie"]!),
];
