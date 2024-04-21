import 'package:tech_knowl_edge_connect/data/topics/biology_topics.dart';
import 'package:tech_knowl_edge_connect/data/topics/computer_science_topics.dart';
import 'package:tech_knowl_edge_connect/data/topics/education_science_topics.dart';
import 'package:tech_knowl_edge_connect/data/topics/math_topics.dart';
import 'package:tech_knowl_edge_connect/models/topic.dart';

Map<String, List<Topic>> computerScienceTopics = {
  "Hardware": hardwareTopics,
  "Software": softwareTopics,
  "Theoretische Informatik": theoryTopics
};

Map<String, List<Topic>> mathTopics = {
  "Unter- und Mittelstufe": foundationalMathTopics,
  "Oberstufe": advancedMathTopics,
};

Map<String, List<Topic>> biologyTopics = {
  "Studium": foundationalBiologyTopics,
};

Map<String, List<Topic>> educationScienceTopics = {
  "Studium": universityeducationScienceTopics,
};

Map<String, Map<String, List<Topic>>> topicMap = {
  "Informatik": computerScienceTopics,
  "Mathematik": mathTopics,
  "Biologie": biologyTopics,
  "Deutsch": {},
  "Psychologie": {},
  "AGD": {},
  "Erziehungswissenschaften": educationScienceTopics,
};
