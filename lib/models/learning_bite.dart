import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';

class LearningBite {
  String name;
  // Text, Video, Aufgabe, Lektion, ...
  LearningBiteType type;
  IconData iconData;
  // explanations
  List<Widget> data;
  List<Task>? tasks;
  bool completed;

  LearningBite({
    required this.name,
    required this.type,
    required this.iconData,
    required this.data,
    this.tasks,
    this.completed = false,
  });
}
