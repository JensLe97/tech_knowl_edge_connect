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
Säugetiere (Mammalia) werden in drei Unterklassen eingeteilt:\n
  1. Monotremata (Kloakentiere)
  2. Marsupialia (Beuteltiere)
  3. Placentalia (Höhere Säugetiere)
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Die Klasse der Säugetiere lässt sich auch in Ordnungen eingeteilt:\n
  1. Kloakentiere
  2. Beuteltiere
  3. Insektenfresser
  4. Nebengelenktiere
  5. Nagetiere
  6. Reißtiere
  7. Herrentiere
  8. Paarhufer
  9. Unpaarhufer
  10. Hasentiere
  11. Fledermäuse
  12. Seekühe
  13. Wale
  14. Rüsseltiere
  15. Naslinge 
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Haare": [
    Column(
      children: [
        const Text("""
Haare sind aus Horn (Eiweiß aus α-Keratin) aufgebaut und haben folgende Funktionen:\n
  1. Wärmeisolation
  2. Tarnung
  3. Sinneswahrnehmung
  4. Verteidigung (Stacheln)
        """),
        SizedBox(
          height: 300,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Milchdrüsen": [
    Column(
      children: [
        const Text("""
Das Hauptmerkmal von Säugetieren ist das Säugen von Nachwuchs mit Milch. Die ventralen (bauchseitige) Milchdrüsen-Streifen sind bei männlichen Säugetieren rudimentär.
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Anteile der Milch:
  1. Wasser (87,5%)
  2. Lactose (7%)
  3. Fett (4%)
  4. Eiweiß (1,5%)
  5. Vitamine
  6. Spurenelemente
  7. Mineralstoffe
  8. Immunglobuline
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Zwerchfell": [
    Column(
      children: [
        const Text("""
Das Zwerchfell ist der wichtigste Atemmuskel zwischen Bauch und Brustraum.
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Knöcherner Gaumen": [
    Column(
      children: [
        const Text("""
Durch den Gaumen ist Saugen sowie Kauen gleichzeitig mit der Atmung möglich. Er ist mit einer Schleimhaut überzogen und unverschieblich mit den Knochen verwachsen.
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Homoiothermie & Endothermie": [
    Column(
      children: [
        const Text("""
Säugetiere sind gleichwarm und können die Körpertemperatur von innen heraus regeln.
Vorteil: Hochleistungslebewesen, Erschließung kalter Lebensräume
Nachteile: Hoher Nahrungsbedarf (im Winter und bei kleinen Arten)
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Getrennte Herzkammern": [
    Column(
      children: [
        const Text("""
Säugetiere haben ein vierkammeriges Herz und die Lungen- und Körperkreislauf ist vollständig getrennt.
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/mammals_cycle.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Sauerstoffreiches Blut gelangt aus der Lunge über Venen ins linke Herz. Dann wird es über Aterien in die Körperkapillaren gepumpt und desoxygeniert.\n
Sauerstoffarmes gelangt aus dem Körper über Venen ins rechte Herz. Dann wird es über die Lungenarterien in die Lungenkapillaren gepumpt und oxygeniert.
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/human_cycle.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Das menschliche Herz:
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/human_heart.png'),
        ),
      ],
    ),
  ],
  "Innere Befruchtung": [
    Column(
      children: [
        const Text("""
Fortpflanzung durch Fortpflanzungsorgane (Penis) und der Nachwuchs wächst im Uterus heran (Außnahme: Kloaken- und Beuteltiere).
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
  ],
  "Heterodontes Gebiss": [
    Column(
      children: [
        const Text("""
Heterodont bedeutet, dass im Gebiss verschiedenartige Zähne vorhanden sind mit unterschiedlichen Funktionen.
Aus der allgemeinen Bezahnung der frühen Insektivoren entwickelten sich verschiedene Fressapparate.
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/biology/early_insectivore.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Je nach Ordnung der Tiere unterscheidet sich der Fressapparat.
  1. Raubtiere: Carnivoren (Fleischfresser)
  2. Nagetiere/(Un)paarhufer: Herbivoren (Pflanzenfresser)
  3. Fledermäuse: Frugivoren (Früchtefresser)
  4. Insektenfresser: Insektivoren
  5. Omnivoren (Allesfresser)
  6. Piscivoren (Fisch/Planktonfresser)
        """),
        SizedBox(
          height: 400,
          child: Image.asset(
              'images/learning_bites/education_science/motivation/motivation.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
  1. Carnivore (Kojote)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/carnivore.png'),
        ),
        const Text("""
  Art: Canis lupus (Wolf)
  Ausgeprägete Canini, Brechschere aus P4 und M1
  Beispiele: Fuchs, Steinmarder, Dachs, Wildkatze
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/carnivore_wolf.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
  2. Herbivoren (Nager)
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/herbivore_biber.png'),
        ),
        const Text("""
  Ordnung: Rodentia (Nagetiere)
  Art: Biber
  Die Incisivi sind Nagezähne (vorne harter Schmelz und hinten weiches Zahnbein), welche zeitlebens wachsen.
  Sie haben keine Canini, aber ein Diastema (Lücke zwischen Zahngruppen)
  Beispiele: Eichhörnchen, Hausmaus, Siebenschläfer, Feldhamster
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/biver.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
  2. Herbivoren (Hase)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/rabbit.png'),
        ),
        const Text("""
  Ordnung: Lagomorpha (Hasenartige)
  2 Paar Incisivi = Nagezähne und Stiftzähne. Nagezähne wachsen zeitlebens
  Sie haben keine Canini, aber ein Diastema und eine gespaltene Oberlippe
  Beispiele: Feldhase, Wildkaninchen
        """),
      ],
    ),
    Column(
      children: [
        const Text("""
  2. Herbivoren (Hirsch)
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/herbivore_gras.png'),
        ),
        const Text("""
  Ordnung: Perissodactyla (Unpaarhufer)
  Incisivi vorhanden. Männchen haben Canini, Diastema, große Molare, die sich zeitlebens abnutzen
  Beispiele: Pferd (Gattung: Equus), Steppenzebra, Breitmaulnashorn
        """),
        const Text("""
  Ordnung: Artiodactyla (Paarhufer)
  Wiederkäuer: oben fehlen Incisivi, keine Canini, Diastema, große Molare
  Außnahme: Schwein als Nichtwiederkäuer hat Incisivi
  Beispiele: Wildschwein, Hausrind, Giraffe, Hirsch (Geweihträger), Ziege (Hornträger)
        """),
      ],
    ),
    Column(
      children: [
        const Text("""
  3. Frugivoren (Flughund)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/frugivore.png'),
        ),
        const Text("""
  Ordnung: Chiroptera (Fledermäuse)
  Lückenloses Gebiss, mehrspitzige Zähne
  Beispiele: Großer Abendsegler, Große Hufeisennase
        """),
      ],
    ),
    Column(
      children: [
        const Text("""
  4. Insektivoren (Zweizehenameisenbär)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/insectivore.png'),
        ),
        const Text("""
  Lückenloses Gebiss, mehrspitzige Zähne
  Beispiele: Maulwurf, Waldspitzmaus, Braunbrustigel
        """),
      ],
    ),
    Column(
      children: [
        const Text("""
  5. Omnivoren (Seidenäffchen)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/omnivore.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
  6. Piscivoren (Delfin)
        """),
        SizedBox(
          height: 400,
          child: Image.asset('images/learning_bites/biology/piscivore.png'),
        ),
        const Text("""
  Ordnung: Cetacea (Wale)
  Sekundäre Homodontie (alle Zähne gleichartig geformt)
  Beispiele: Buckelwal, Großer Tümmler
        """),
      ],
    ),
    Column(
      children: [
        const Text("""
Unterkiefer eines Omnivore (Vielzwecksatz an Zähnen)
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/omnivore_teeth.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Unterkiefer eines Carnivore: Fangzähne und Brechschere (Prämolaren mit Molaren zu Reißzähnen verschmolzen)
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/carnivore_teeth.png'),
        ),
      ],
    ),
    Column(
      children: [
        const Text("""
Unterkiefer eines Herbivore (Schneide- und Eckzähne zum Abreißen von Blättern)
        """),
        SizedBox(
          height: 400,
          child:
              Image.asset('images/learning_bites/biology/herbivore_teeth.png'),
        ),
      ],
    ),
  ],
};

Map<String, List<Task>> tasks = {
  "Allgemeine Merkmale": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Säugetiere werden auch {} genannt.",
        correctAnswer: "Synapsiden",
        answers: ["Synapsiden", "Sauropsiden"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Reptilien und Vögel werden auch {} genannt.",
        correctAnswer: "Sauropsiden",
        answers: ["Synapsiden", "Sauropsiden"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nKeine Plazenta",
        correctAnswer: "Kloakentiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\n240 Arten",
        correctAnswer: "Beuteltiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nMilch aus Hautdrüsen",
        correctAnswer: "Kloakentiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nLegen Eier (ovipar)",
        correctAnswer: "Kloakentiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nVersorgung über Plazenta",
        correctAnswer: "Höhere Säugetiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nGeburt im embryoartigen Stadium (vivipar)",
        correctAnswer: "Beuteltiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\n4500 Arten (94% aller Säugetiere)",
        correctAnswer: "Höhere Säugetiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nZitzen im Beutel",
        correctAnswer: "Beuteltiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\n2 Arten (Ameisenigel und Schnabeltier)",
        correctAnswer: "Kloakentiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
    Task(
        type: TaskType.singleChoice,
        question: "Ordne zu:\nTragezeit: 16-22 Monate",
        correctAnswer: "Höhere Säugetiere",
        answers: ["Kloakentiere", "Beuteltiere", "Höhere Säugetiere"]),
  ],
  "Milchdrüsen": [
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Duftdrüsen dienen der {}.",
        correctAnswer: "Kommunikation",
        answers: ["Wärmeregulation", "Einfettung der Haare", "Kommunikation"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Schweißdrüsen dienen der {}.",
        correctAnswer: "Wärmeregulation",
        answers: ["Wärmeregulation", "Einfettung der Haare", "Kommunikation"]),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Talgdrüsen dienen der {}.",
        correctAnswer: "Einfettung der Haare",
        answers: ["Wärmeregulation", "Einfettung der Haare", "Kommunikation"]),
  ],
  "Knöcherner Gaumen": [
    Task(
        type: TaskType.singleChoice,
        question: "Harter Gaumen",
        correctAnswer: "Vorderer Teil",
        answers: ["Vorderer Teil", "Hinterer Teil"]),
    Task(
        type: TaskType.singleChoice,
        question: "Weicher Gaumen",
        correctAnswer: "Hinterer Teil",
        answers: ["Vorderer Teil", "Hinterer Teil"]),
  ],
  "Heterodontes Gebiss": [
    Task(
        type: TaskType.singleChoice,
        question: "Was sind die Fachbegriffe:\nVordere Backenzähne",
        correctAnswer: "Prämolare",
        answers: ["Incisivi", "Caninus", "Prämolare", "Molare"]),
    Task(
        type: TaskType.singleChoice,
        question: "Was sind die Fachbegriffe:\nEck- oder Reißzahn",
        correctAnswer: "Caninus",
        answers: ["Incisivi", "Caninus", "Prämolare", "Molare"]),
    Task(
        type: TaskType.singleChoice,
        question: "Was sind die Fachbegriffe:\nSchneidezähne",
        correctAnswer: "Incisivi",
        answers: ["Incisivi", "Caninus", "Prämolare", "Molare"]),
    Task(
        type: TaskType.singleChoice,
        question: "Was sind die Fachbegriffe:\nBackenzähne",
        correctAnswer: "Molare",
        answers: ["Incisivi", "Caninus", "Prämolare", "Molare"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question: "Wie lautet die Zahnformel beim Menschen?\n{}I {}C {}P {}M",
        correctAnswer: "2{}1{}2{}3",
        answers: []),
    Task(
        type: TaskType.singleChoiceCloze,
        question: "Unpaarhufer haben eine {} Anzahl an Zehen",
        correctAnswer: "ungerade",
        answers: ["gerade", "ungerade"]),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Zu den Unpaarhufern gehören die Familien der Pferde, Nashörner und {}.",
        correctAnswer: "Tapire",
        answers: []),
    Task(
        type: TaskType.freeTextFieldCloze,
        question:
            "Zu den Paarhufern gehören die Familien der Flusspferde, Wiederkäuer, Schweineartige und {}.",
        correctAnswer: "Kamele",
        answers: []),
  ],
  "Fachbegriffe": [
    Task(
      type: TaskType.indexCard,
      question: "Kloakentiere",
      correctAnswer: "Monotremata",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Beuteltiere",
      correctAnswer: "Marsupialia",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Höhere Säugetiere",
      correctAnswer: "Placentalia",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Gleichwarm",
      correctAnswer: "Homoiotherm / Endotherm",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Wechselwarm",
      correctAnswer: "Poikilotherm / Ektotherm",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Fleischfresser",
      correctAnswer: "Carnivoren",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Allesfresser",
      correctAnswer: "Omnivoren",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Pflanzenfresser",
      correctAnswer: "Herbivoren",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Schneidezähne",
      correctAnswer: "Incisivi",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Eck- oder Reißzahn",
      correctAnswer: "Caninus (pl. Canini)",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Vorderbackenzähne",
      correctAnswer: "Prämolare",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Backenzähne",
      correctAnswer: "Molare",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Nagetiere",
      correctAnswer: "Rodentia",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Lücke zwischen Zahngruppen",
      correctAnswer: "Diastem",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Eichhörnchen",
      correctAnswer: "Sciurus vulgaris",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Hausmaus",
      correctAnswer: "Mus musculus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Siebenschläfer",
      correctAnswer: "Glis glis",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Feldhamster",
      correctAnswer: "Cricetus cricetus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Hasenartige",
      correctAnswer: "Lagomorpha",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Feldhase",
      correctAnswer: "Lepus europaeus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Wildkaninchen",
      correctAnswer: "Oryctolagus cuniculus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Raubtiere",
      correctAnswer: "Canivora",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Wolf",
      correctAnswer: "Canis lupus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Fuchs",
      correctAnswer: "Vulpes vulpes",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Wildkatze",
      correctAnswer: "Felis silvestris",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Steinmarder",
      correctAnswer: "Martes foina",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Dachs",
      correctAnswer: "Meles meles",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Unpaarhufer",
      correctAnswer: "Perissodactyla",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Pferd",
      correctAnswer: "Equus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Steppenzebra",
      correctAnswer: "Equus quagga",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Breitmaulnashorn",
      correctAnswer: "Ceratotherium simum",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Paarhufer",
      correctAnswer: "Artiodactyla",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Wildschwein",
      correctAnswer: "Sus scrofa",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Insektenfresser",
      correctAnswer: "Insektivora",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Maulwurf",
      correctAnswer: "Talpa europaea",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Waldspitzmaus",
      correctAnswer: "Sorex araneus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Braunbrustigel",
      correctAnswer: "Erinaceus europaeus",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Fledermäuse",
      correctAnswer: "Chiroptera",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Großer Abendsegler",
      correctAnswer: "Nyctalus noctula",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Große Hufeisennase",
      correctAnswer: "Rhinolophus ferrumequinum",
    ),
    Task(
      type: TaskType.indexCard,
      question: "Wale",
      correctAnswer: "Cetacea",
    ),
  ],
};

List<LearningBite> mammalsLearningBites = [
  LearningBite(
      name: "Allgemeine Merkmale",
      type: LearningBiteType.lesson,
      data: data["Allgemeine Merkmale"]!,
      iconData: FontAwesomeIcons.horseHead,
      tasks: tasks["Allgemeine Merkmale"]!),
  LearningBite(
    name: "Haare",
    type: LearningBiteType.text,
    data: data["Haare"]!,
    iconData: FontAwesomeIcons.cat,
  ),
  LearningBite(
      name: "Milchdrüsen",
      type: LearningBiteType.lesson,
      data: data["Milchdrüsen"]!,
      iconData: FontAwesomeIcons.hippo,
      tasks: tasks["Milchdrüsen"]!),
  LearningBite(
    name: "Zwerchfell",
    type: LearningBiteType.text,
    data: data["Zwerchfell"]!,
    iconData: FontAwesomeIcons.lungs,
  ),
  LearningBite(
      name: "Knöcherner Gaumen",
      type: LearningBiteType.lesson,
      data: data["Knöcherner Gaumen"]!,
      iconData: FontAwesomeIcons.dog,
      tasks: tasks["Knöcherner Gaumen"]!),
  LearningBite(
    name: "Homoiothermie & Endothermie",
    type: LearningBiteType.text,
    data: data["Homoiothermie & Endothermie"]!,
    iconData: FontAwesomeIcons.horse,
  ),
  LearningBite(
    name: "Getrennte Herzkammern",
    type: LearningBiteType.text,
    data: data["Getrennte Herzkammern"]!,
    iconData: FontAwesomeIcons.heart,
  ),
  LearningBite(
    name: "Innere Befruchtung",
    type: LearningBiteType.text,
    data: data["Innere Befruchtung"]!,
    iconData: FontAwesomeIcons.otter,
  ),
  LearningBite(
      name: "Heterodontes Gebiss",
      type: LearningBiteType.lesson,
      data: data["Heterodontes Gebiss"]!,
      iconData: FontAwesomeIcons.teeth,
      tasks: tasks["Heterodontes Gebiss"]!),
  LearningBite(
      name: "Fachbegriffe",
      type: LearningBiteType.lesson,
      data: [],
      iconData: FontAwesomeIcons.checkDouble,
      tasks: tasks["Fachbegriffe"]!),
];
