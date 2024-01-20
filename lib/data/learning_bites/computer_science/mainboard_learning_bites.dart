import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

Map<String, List<Widget>> data = const {
  "Mainboard - Einfach erklärt": [
    Text(
        "Auf dem Mainboard befinden sich verschiedene Komponenten eines Computers, die über kurze Distanzen verbunden sind und miteinander kommonizieren."),
    Divider(
      thickness: 1,
    ),
  ],
  "Mainboardaufbau": [
    Text(
        "Die wichtigsten Komponenten sind die CPU, der RAM und die Anschlüsse for externe Geräte."),
    Divider(
      thickness: 1,
    ),
  ]
};

List<LearningBite> mainboardLearningBites = [
  LearningBite(
      name: "Mainboard - Einfach erklärt",
      type: LearningBiteType.text,
      data: data["Mainboard - Einfach erklärt"]!,
      iconData: FontAwesomeIcons.pager),
  LearningBite(
      name: "Mainboardaufbau",
      type: LearningBiteType.video,
      data: data["Mainboardaufbau"]!,
      iconData: Icons.view_compact),
];
