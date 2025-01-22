import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

Map<String, List<Widget>> data = const {
  "CPU - Einfach erklärt": [
    Text("Die CPU oder auf der Prozessor ist das Herz des Computers."),
  ],
  "CPU Aufbau": [
    Text("Eine CPU besteht aus Milliarden von Transistoren."),
  ]
};

List<LearningBite> cpuLearningBites = [
  LearningBite(
      name: "CPU - Einfach erklärt",
      type: LearningBiteType.text,
      data: data["CPU - Einfach erklärt"]!,
      iconData: FontAwesomeIcons.microchip),
  LearningBite(
      name: "CPU Aufbau",
      type: LearningBiteType.video,
      data: data["CPU Aufbau"]!,
      iconData: Icons.view_list),
];
