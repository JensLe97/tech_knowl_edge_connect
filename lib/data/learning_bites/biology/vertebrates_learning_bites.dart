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
        question: "Ordne das Zeitalter der Entstehung zu:\n\t1. Wirbeltiere",
        correctAnswer: "Kambrium (545 - 495 Mio.)",
        answers: [
          "Trias (250 - 208 Mio.)",
          "Devon (410 - 355 Mio.)",
          "Kambrium (545 - 495 Mio.)",
          "Jura (208 - 144 Mio.)",
          "Silur (443 - 410 Mio.)",
          "Perm (298 - 250 Mio.)",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne das Zeitalter der Entstehung zu:\n\t1. Fische (55%)",
        correctAnswer: "Silur (443 - 410 Mio.)",
        answers: [
          "Trias (250 - 208 Mio.)",
          "Devon (410 - 355 Mio.)",
          "Kambrium (545 - 495 Mio.)",
          "Jura (208 - 144 Mio.)",
          "Silur (443 - 410 Mio.)",
          "Perm (298 - 250 Mio.)",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne das Zeitalter der Entstehung zu:\n\t2. Amphibien (5%)",
        correctAnswer: "Devon (410 - 355 Mio.)",
        answers: [
          "Trias (250 - 208 Mio.)",
          "Devon (410 - 355 Mio.)",
          "Kambrium (545 - 495 Mio.)",
          "Jura (208 - 144 Mio.)",
          "Silur (443 - 410 Mio.)",
          "Perm (298 - 250 Mio.)",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne das Zeitalter der Entstehung zu:\n\t3. Reptilien (12%)",
        correctAnswer: "Perm (298 - 250 Mio.)",
        answers: [
          "Trias (250 - 208 Mio.)",
          "Devon (410 - 355 Mio.)",
          "Kambrium (545 - 495 Mio.)",
          "Jura (208 - 144 Mio.)",
          "Silur (443 - 410 Mio.)",
          "Perm (298 - 250 Mio.)",
        ]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Ordne das Zeitalter der Entstehung zu:\n\t4. Säugetiere (8%)",
        correctAnswer: "Trias (250 - 208 Mio.)",
        answers: [
          "Trias (250 - 208 Mio.)",
          "Devon (410 - 355 Mio.)",
          "Kambrium (545 - 495 Mio.)",
          "Jura (208 - 144 Mio.)",
          "Silur (443 - 410 Mio.)",
          "Perm (298 - 250 Mio.)",
        ]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne das Zeitalter der Entstehung zu:\n\t5. Vögel (16%)",
        correctAnswer: "Jura (208 - 144 Mio.)",
        answers: [
          "Trias (250 - 208 Mio.)",
          "Devon (410 - 355 Mio.)",
          "Kambrium (545 - 495 Mio.)",
          "Jura (208 - 144 Mio.)",
          "Silur (443 - 410 Mio.)",
          "Perm (298 - 250 Mio.)",
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
  "Fachbegriffe": [
    Task(
      type: TaskType.indexCard,
      question: "Gelenkige Wirbelsäule (langer biegsamer Stab im Rücken)",
      correctAnswer: "Chorda dorsalis",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Oberhaut",
      correctAnswer: "Epidermis",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Zeitalter Fische",
      correctAnswer: "Silur (443 - 410 Mio.)",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Zeitalter Amphibien",
      correctAnswer: "Devon (410 - 355 Mio.)",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Zeitalter Reptilien",
      correctAnswer: "Perm (298 - 250 Mio.)",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Zeitalter Säugetiere",
      correctAnswer: "Trias (250 - 208 Mio.)",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Zeitalter Vögel",
      correctAnswer: "Jura (208 - 144 Mio.)",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Fachbegriff Säugetiere",
      correctAnswer: "Synapsiden",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Fachbegriff Reptilien und Vögel",
      correctAnswer: "Sauropsiden",
    ),
  ],
};

List<LearningBite> vertebratesIntroLearningBites = [
  LearningBite(
      name: "Allgemeine Merkmale",
      type: LearningBiteType.lesson,
      data: data["Allgemeine Merkmale"]!,
      iconData: FontAwesomeIcons.paw,
      tasks: tasks["Allgemeine Merkmale"]!),
  LearningBite(
      name: "Fachbegriffe",
      type: LearningBiteType.lesson,
      data: [],
      iconData: FontAwesomeIcons.checkDouble,
      tasks: tasks["Fachbegriffe"]!),
];
