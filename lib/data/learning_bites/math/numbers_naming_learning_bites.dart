import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/task_type.dart';

Map<String, List<Widget>> data = {
  "Natürliche Zahlen": [
    Column(
      children: [
        const Text("Zahlen von 1 bis unendlich. Also 1, 2, 3, 4, ..."),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/math/numbers_naming/numbers.png'),
        ),
      ],
    ),
  ],
  "Ganze Zahlen": [
    Column(
      children: [
        const Text(
            "Natürliche Zahlen und negative ganzzahlige (..., -2, -1, 0, 1, 2, ...)."),
        SizedBox(
          height: 500,
          child: Image.asset(
              'images/learning_bites/math/numbers_naming/numbers.png'),
        ),
      ],
    ),
  ],
  "Rechengesetze": [
    Column(
      children: [
        const Text(
            "Es gibt 3 grundlegende Rechengesetze. Das Kommutativgesetz, das Assoziativgesetz und das Distributivgesetz."),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/math/numbers_naming/numbers.png'),
        ),
      ],
    ),
  ],
  "Gruppen": [
    Column(
      children: [
        const Text(
            "Eine Gruppe ist eine mathematische Struktur, also eine Klasse von Objekten, die alle die gleichen Eigenschaften haben. Diese Objekte sind im Falle der Gruppe eine nichtleere Menge M. Außerdem hat eine Gruppe (M, &) immer eine Verküpfung & definiert."),
        const SizedBox(height: 30),
        SizedBox(
          height: 200,
          child: Image.asset(
              'images/learning_bites/math/numbers_naming/numbers.png'),
        ),
      ],
    ),
  ],
  "Abstrakte endliche Gruppen": [
    Column(
      children: [
        const Text(
            "Eine abstrakte endliche Gruppe kann man vollständig durch eine Gruppentafel beschreiben. Die Anzahl der Elemente in einer endlichen Gruppe nennt man Ordnung."),
        const SizedBox(height: 30),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/math/numbers_naming/numbers.png'),
        ),
      ],
    ),
  ],
  "Mengenlehre": [
    Column(
      children: [
        const Text(
            "Eine Menge ist eine Zusammenfassung von bestimmten wohlunterschiedenen Objekten zu einem Ganzen. Diese Objekte werden Elemente genannt. Zwei Mengen A und B nennt man genau dann gleich (A = B), wenn jedes Element von A auch Element von B ist und umgekehrt."),
        const SizedBox(height: 30),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/math/numbers_naming/numbers.png'),
        ),
      ],
    ),
  ]
};

Map<String, List<Task>> tasks = {
  "Natürliche Zahlen": [
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl 5 eine natürliche Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein", "Vielleicht"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl -2 eine natürliche Zahl?",
        correctAnswer: "Nein",
        answers: ["Ja", "Nein"]),
  ],
  "Ganze Zahlen": [
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl 5 eine ganze Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ist die Zahl -2 eine ganze Zahl?",
        correctAnswer: "Ja",
        answers: ["Ja", "Nein"]),
  ],
  "Rechengesetze": [
    Task(
        type: TaskType.singleChoice,
        question: "Wie lautet das Kommutativgesetz?",
        correctAnswer: "a + b = b + a",
        answers: ["a + b = b + a", "a - b = b - a"]),
    Task(
        type: TaskType.singleChoice,
        question: "Welches Gesetz lautet a * (b + c) = a * b + a * c?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz wird hier angewendet: 9 + 2 + 10 = 9 + 10 + 2?",
        correctAnswer: "Assoziativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question: "Welches Gesetz behandelt das 'Vertauschen' von zwei Zahlen?",
        correctAnswer: "Kommutativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz wird hier angewendet: 9 * (2 + 10) = 9 * 2 + 9 * 10?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz behandelt das 'Verbinden/Verknüpfen' in beliebiger Reihenfolge?",
        correctAnswer: "Assoziativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Welches Gesetz behandelt das 'Aufteilen/Verteilen' von einer Zahl auf zwei andere Zahlen?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question: "Das Assoziativgesetz lautet a * b = b * a",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bei welchem Gesetz lässt sich das Plus mit einem Minus ersetzen?",
        correctAnswer: "Distributiv",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
  ],
  "Gruppen": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Abgeschlossen bedeteutet: Für beliebige a, b aus der Menge M gilt stets, dass auch (a & b) aus M ist.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Für eine Gruppe gilt: Die Menge M ist bezüglich der Verküpfung & abgeschlossen.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "Welches Gesetz gilt als ein Axiom in (M, &)?",
        correctAnswer: "Assoziativ",
        answers: ["Kommutativ", "Distributiv", "Assoziativ"]),
    Task(
        type: TaskType.singleChoice,
        question: "In einer Gruppe existiert immer ein neutrales Element e?",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Für eine Gruppe gilt: Zu jedem Element x aus M gibt es ein inverses Element y aus M?",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Wie nennt man e mit dieser Eigenschaft: Für alle c aus M gilt: c & e = e & c = c?",
        correctAnswer: "Neutrales Element",
        answers: ["Neutrales Element", "Inverses Element"]),
    Task(
        type: TaskType.singleChoice,
        question: "Wie nennt man y mit dieser Eigenschaft: x & y = y & x = e?",
        correctAnswer: "Inverses Element",
        answers: ["Neutrales Element", "Inverses Element"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die natürlichen Zahlen N mit dem '+' Operator bilden eine Gruppe (N, +)",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die ganzen Zahlen Z mit dem '+' Operator bilden eine Gruppe (Z, +)",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die ganzen Zahlen Z mit dem '*' Operator bilden eine Gruppe (Z, *)",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die rationalen Zahlen Q mit dem '+' Operator bilden eine Gruppe (Q, +)",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Die rationalen Zahlen Q ohne die Null mit dem '*' Operator bilden eine Gruppe (Q \\ {0}, *)",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
  ],
  "Abstrakte endliche Gruppen": [
    Task(
        type: TaskType.singleChoice,
        question:
            "Es gibt genau eine abstrakte endliche Gruppe der Ordnung 1, der Ordnung 2 und der Ordnung 3.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Für abstrakte endliche Gruppen mit höherer Ordnung als 3 lässt sich immer nur eine Gruppentafel finden.",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "Was bedeutet isomorph?",
        correctAnswer: "Strukturgleich",
        answers: ["Identisch", "Strukturgleich", "Ungleich"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Zyklische Gruppen sind Gruppen die mindestens eine Drehung besitzen.",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Eine Diedergruppe ist eine Gruppe, die gleichviele Drehungen wie Spiegelungen besitzen.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "Wie viele endliche Gruppen der Ordnung 4 gibt es?",
        correctAnswer: "2",
        answers: ["1", "2", "3", "4"]),
  ],
  "Mengenlehre": [
    Task(
        type: TaskType.singleChoice,
        question:
            "In einer Menge ist die Reihenfolge der Elemente unerheblich.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "In einer Menge können Elemente mehrfach enthalten sein.",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "Wie lässt sich die leere Menge außer mit ∅ noch darstellen?",
        correctAnswer: "{}",
        answers: ["[]", "<>", "{}", "()"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Eine Menge A nennt man Teilmenge einer Menge B (A ⊆ B), wenn jedes Element von A auch Element von B ist.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "A = {2, 3, 6} und B = {2, 4, 5, 6, 8}, dann ist A ⊆ B",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Bestimme den Durchschnitt bzw. die Schnittmenge von A = {2, 3, 6} und B = {2, 4, 5, 6, 8}",
        correctAnswer: "{2, 6}",
        answers: ["{2, 4, 5}", "{2, 3}", "{2, 3, 6}", "{2, 6}"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Wie lautet der Name dieser Mengendefinition von den Mengen A und B: A \\ B = {x | x ∈ A ∧ x ∉ B}",
        correctAnswer: "Differenzmenge",
        answers: ["Schnittmenge", "Differenzmenge", "Teilmenge"]),
    Task(
        type: TaskType.singleChoice,
        question: "Falls A ⊂ B dann gilt für die Differenzmenge: A \\ B = {}?",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Falls A ∩ B = {} dann gilt für die Differenzmenge: A \\ B = {}?",
        correctAnswer: "Falsch",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question: "Falls A = B dann gilt für die Differenzmenge: A \\ B = {}?",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
    Task(
        type: TaskType.singleChoice,
        question:
            "Für die Mengen A und B gilt das Kommutativ-, Assoziativ- und das Distributivgesetzt mit jeweils den Operatoren ∩ und ∪.",
        correctAnswer: "Wahr",
        answers: ["Wahr", "Falsch"]),
  ]
};

List<LearningBite> importantNumbersLearningBites = [
  LearningBite(
      name: "Natürliche Zahlen",
      type: LearningBiteType.lesson,
      data: data["Natürliche Zahlen"]!,
      iconData: FontAwesomeIcons.arrowUp91,
      tasks: tasks["Natürliche Zahlen"]!),
  LearningBite(
      name: "Ganze Zahlen",
      type: LearningBiteType.lesson,
      data: data["Ganze Zahlen"]!,
      iconData: FontAwesomeIcons.arrowDown91,
      tasks: tasks["Ganze Zahlen"]!),
  LearningBite(
      name: "Rechengesetze",
      type: LearningBiteType.lesson,
      data: data["Rechengesetze"]!,
      iconData: Icons.calculate,
      tasks: tasks["Rechengesetze"]!),
  LearningBite(
      name: "Gruppen",
      type: LearningBiteType.lesson,
      data: data["Gruppen"]!,
      iconData: FontAwesomeIcons.layerGroup,
      tasks: tasks["Gruppen"]!),
  LearningBite(
      name: "Abstrakte endliche Gruppen",
      type: LearningBiteType.lesson,
      data: data["Abstrakte endliche Gruppen"]!,
      iconData: FontAwesomeIcons.objectGroup,
      tasks: tasks["Abstrakte endliche Gruppen"]!),
  LearningBite(
      name: "Mengenlehre",
      type: LearningBiteType.lesson,
      data: data["Mengenlehre"]!,
      iconData: FontAwesomeIcons.diagramProject,
      tasks: tasks["Mengenlehre"]!),
];
