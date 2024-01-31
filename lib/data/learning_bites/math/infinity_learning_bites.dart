import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

Map<String, List<Widget>> data = const {
  "Hilberts Hotel": [
    Text("Ein Hotel mit unendlich vielen Zimmern"),
    Divider(
      thickness: 1,
    ),
  ],
  "Unendlichkeitsparadoxon": [
    Text("."),
    Divider(
      thickness: 1,
    ),
  ]
};

List<LearningBite> infinityLearningBites = [
  LearningBite(
      name: "Hilberts Hotel",
      type: LearningBiteType.text,
      data: data["Hilberts Hotel"]!,
      iconData: FontAwesomeIcons.hotel),
  LearningBite(
      name: "Unendlichkeitsparadoxon",
      type: LearningBiteType.video,
      data: data["Unendlichkeitsparadoxon"]!,
      iconData: FontAwesomeIcons.infinity),
];
