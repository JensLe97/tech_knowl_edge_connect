import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

Map<String, List<Widget>> data = const {
  "HTML Struktur - Allgemein": [
    Text("HTML besteht aus einem header und einem body Bereich."),
    Divider(
      thickness: 1,
    ),
  ],
  "HTML Struktur Elemente": [
    Text("Weitere Elemente sind paragraph und heading."),
    Divider(
      thickness: 1,
    ),
  ]
};

List<LearningBite> htmlStructureLearningBites = [
  LearningBite(
      name: "HTML Struktur - Allgemein",
      type: LearningBiteType.text,
      data: data["HTML Struktur - Allgemein"]!,
      iconData: Icons.web),
  LearningBite(
      name: "HTML Struktur Elemente",
      type: LearningBiteType.video,
      data: data["HTML Struktur Elemente"]!,
      iconData: FontAwesomeIcons.elementor),
];
