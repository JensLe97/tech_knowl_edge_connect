import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

class LearningBite {
  String name;
  // Text, Video, Aufgabe, Lektion, ...
  LearningBiteType type;
  IconData iconData;
  // explanations
  List<Widget> data;

  LearningBite({
    required this.name,
    required this.type,
    required this.iconData,
    required this.data,
  });
}
