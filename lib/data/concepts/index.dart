import 'package:tech_knowl_edge_connect/data/concepts/computer_science/component_concepts.dart';
import 'package:tech_knowl_edge_connect/data/concepts/computer_science/html_concepts.dart';
import 'package:tech_knowl_edge_connect/data/concepts/math/number_categories_concepts.dart';
import 'package:tech_knowl_edge_connect/models/concept.dart';

// ===== Units =====
// Computer Sciene
Map<String, List<Concept>> computerConcepts = {
  "Komponenten": componentConcepts,
};

Map<String, List<Concept>> webLangConcepts = {
  "HTML": htmlConcepts,
};

// Math
Map<String, List<Concept>> numbersConcepts = {
  "Zahlenarten": numberCategoriesConcepts,
};

// Biology

// ===== Topics =====
// Computer Sciene
Map<String, Map<String, List<Concept>>> hardwareComputerScienceConcepts = {
  "Computer": computerConcepts,
};
Map<String, Map<String, List<Concept>>> softwareComputerScienceConcepts = {
  "Websprachen": webLangConcepts,
  "Java": {},
};
Map<String, Map<String, List<Concept>>> theoryComputerScienceConcepts = {
  "Rechnerorganisation": {},
  "Datenbanken": {},
};

// Math
Map<String, Map<String, List<Concept>>> foundationalMathConcepts = {
  "Zahlen": numbersConcepts,
  "Geometrie": {},
};
Map<String, Map<String, List<Concept>>> advancedMathConcepts = {
  "Analysis": {},
  "Lineare Algebra": {},
};

// Biology
Map<String, Map<String, List<Concept>>> foundationalBiologyConcepts = {
  "Tiere": {},
  "Pflanzen": {},
};

// ===== Categories =====
Map<String, Map<String, Map<String, List<Concept>>>> computerScienceConcepts = {
  "Hardware": hardwareComputerScienceConcepts,
  "Software": softwareComputerScienceConcepts,
  "Theoretische Informatik": theoryComputerScienceConcepts,
};

Map<String, Map<String, Map<String, List<Concept>>>> mathConcepts = {
  "Unter- und Mittelstufe": foundationalMathConcepts,
  "Oberstufe": advancedMathConcepts,
};

Map<String, Map<String, Map<String, List<Concept>>>> biologyConcepts = {
  "Mittelstufe": foundationalBiologyConcepts,
};

// ===== Global =====
// Subject   , Category, Topic   , Unit       , Concept
// Informatik, Hardware, Computer, Komponenten, Mainboard
Map<String, Map<String, Map<String, Map<String, List<Concept>>>>> conceptMap = {
  "Informatik": computerScienceConcepts,
  "Mathematik": mathConcepts,
  "Biologie": biologyConcepts,
};
