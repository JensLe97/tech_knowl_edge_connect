// ignore_for_file: unused_element

import "package:flutter/material.dart";
import 'package:tech_knowl_edge_connect/models/category.dart';

class Subject {
  String name;
  Color color;
  IconData iconData;
  // e.g. Software, Hardwar, Theorie, ...
  late List<Category> _categories;

  Subject({
    required this.name,
    required this.color,
    required this.iconData,
  });

  Color get _color => color;
  String get _name => name;
  IconData get _iconData => iconData;
  List<Category> get categories => _categories;
}
