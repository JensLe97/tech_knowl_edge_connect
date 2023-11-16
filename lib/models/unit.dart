// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/concept.dart';

class Unit {
  String name;
  IconData iconData;
  // e.g. DEA, PDA, NEA, ...
  List<Concept> concepts;

  Unit({
    required this.concepts,
    required this.name,
    required,
    required this.iconData,
  });

  String get _name => name;
  IconData get _iconData => iconData;
  List<Concept> get _learningBites => concepts;
}
