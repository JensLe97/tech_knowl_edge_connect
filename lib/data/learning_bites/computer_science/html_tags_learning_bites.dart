import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

Map<String, List<Widget>> data = const {
  "Der div Tag": [
    Text("Ein einfacher Wrapper für ein anderes Element."),
  ],
  "Der p Tag": [
    Text("Dieser Tag kennzeichnet einen Paragraphen."),
  ]
};

List<LearningBite> htmlTagsLearningBites = [
  LearningBite(
      name: "Der div Tag",
      type: LearningBiteType.text,
      data: data["Der div Tag"]!,
      iconData: FontAwesomeIcons.lessThan),
  LearningBite(
      name: "Der p Tag",
      type: LearningBiteType.video,
      data: data["Der p Tag"]!,
      iconData: FontAwesomeIcons.paragraph),
];
