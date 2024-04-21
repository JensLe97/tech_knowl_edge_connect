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
Wirbeltiere haben folgende allgemeine Merkmale:\n
1. Gelenkige Wirbelsäule
2. Endoskelett (innen)
3. Zwei Extremitätenpaare
4. Organe aufgehängt in Coelom (Bauch/Brusthöhle)
5. Schädel mit Gehirn
6. Kreislaufsystem mit ventralem Herzen (bauchseitig)
7. Mehrschichtige Epidermis
        """),
        SizedBox(
          height: 200,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Außerdem besitzen Wirbeltiere:\n
1. Labyrinthorgan (Gleichgewichtsorgan im Ohr)
2. Gehirnnerven
3. Neurocranium (Schädel)
4. Spinalganglien
        """),
        SizedBox(
          height: 200,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
};

Map<String, List<Task>> tasks = {
  "Allgemeine Merkmale": [
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Der lange biegsamer Stab im Rückenbereich, der die Wirbeltiere ausmacht, nennt man: {}.",
        correctAnswer: "Chorda dorsalis",
        answers: []),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bringe die Klassen in die richtige chronologische Reihenfolge ihrer Entstehung:\n\t1. Silur",
        correctAnswer: "Fische (48%)",
        answers: [
          "Säugetiere (9%)",
          "Fische (48%)",
          "Vögel (18%)",
          "Reptilien (15%)",
          "Amphibien (10%)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bringe die Klassen in die richtige chronologische Reihenfolge ihrer Entstehung:\n\t2. Devon",
        correctAnswer: "Amphibien (10%)",
        answers: [
          "Säugetiere (9%)",
          "Fische (48%)",
          "Vögel (18%)",
          "Reptilien (15%)",
          "Amphibien (10%)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bringe die Klassen in die richtige chronologische Reihenfolge ihrer Entstehung:\n\t3. Perm",
        correctAnswer: "Reptilien (15%)",
        answers: [
          "Säugetiere (8%)",
          "Fische (55%)",
          "Vögel (16%)",
          "Reptilien (12%)",
          "Amphibien (5%)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bringe die Klassen in die richtige chronologische Reihenfolge ihrer Entstehung:\n\t4. Trias",
        correctAnswer: "Säugetiere (9%)",
        answers: [
          "Säugetiere (9%)",
          "Fische (48%)",
          "Vögel (18%)",
          "Reptilien (15%)",
          "Amphibien (10%)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bringe die Klassen in die richtige chronologische Reihenfolge ihrer Entstehung:\n\t5. Jura",
        correctAnswer: "Vögel (18%)",
        answers: [
          "Säugetiere (9%)",
          "Fische (48%)",
          "Vögel (18%)",
          "Reptilien (15%)",
          "Amphibien (10%)"
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Seekatzen, Schleimaale und Quastenflosser haben kein Wirbelsäule, sondern nur eine Chorda dorsalis.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question:
            "Federn, Schuppen oder Fell sind Strukturen auf der oberersten Hautschicht, der mehrschichtigen {}.",
        correctAnswer: "Epidermis",
        answers: ["Epidermis", "Membrana cellularis"]),
  ],
};

List<LearningBite> vertebratesIntroLearningBites = [
  LearningBite(
      name: "Allgemeine Merkmale",
      type: LearningBiteType.lesson,
      data: data["Allgemeine Merkmale"]!,
      iconData: FontAwesomeIcons.paw,
      tasks: tasks["Allgemeine Merkmale"]!),
];
