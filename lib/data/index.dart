import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/data/topics/index.dart';
import 'package:tech_knowl_edge_connect/models/category.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';

List<Category> computerScienceCategories = [
  Category(name: "Hardware", topics: topicMap["Informatik"]!["Hardware"]!),
  Category(name: "Software", topics: topicMap["Informatik"]!["Software"]!),
  Category(
      name: "Theoretische Informatik",
      topics: topicMap["Informatik"]!["Theoretische Informatik"]!),
];

List<Category> mathCategories = [
  Category(
      name: "Unter- und Mittelstufe",
      topics: topicMap["Mathematik"]!["Unter- und Mittelstufe"]!),
  Category(name: "Oberstufe", topics: topicMap["Mathematik"]!["Oberstufe"]!),
];

List<Category> biologyCategories = [
  Category(name: "Mittelstufe", topics: topicMap["Biologie"]!["Mittelstufe"]!),
];

// ===== Global =====
Map<String, List<Category>> categoryMap = {
  "Informatik": computerScienceCategories,
  "Mathematik": mathCategories,
  "Biologie": biologyCategories
};

List<Subject> subjects = [
  Subject(
    name: "Informatik",
    color: Colors.blueGrey.shade400,
    iconData: Icons.computer,
  ),
  Subject(
    name: "Mathematik",
    color: Colors.blue.shade800,
    iconData: FontAwesomeIcons.calculator,
  ),
  Subject(
    name: "Biologie",
    color: Colors.green.shade600,
    iconData: FontAwesomeIcons.tree,
  ),
];

List<List<int>> resumeSubjects = [];
List<List<int>> completedLearningBites = [];
