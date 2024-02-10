import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/cpu_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/html_structure_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/html_tags_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/mainboard_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/expectation_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/motivation_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/value_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/volition_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/math/infinity_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/math/numbers_naming_learning_bites.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';

// ===== Concepts =====
// Computer Sciene
Map<String, List<LearningBite>> componentLearningBites = {
  "Mainboard": mainboardLearningBites,
  "CPU": cpuLearningBites,
};

Map<String, List<LearningBite>> htmlLearningBites = {
  "HTML Struktur": htmlStructureLearningBites,
  "HTML Tags": htmlTagsLearningBites,
};

// Math
Map<String, List<LearningBite>> numbersNamingLearningBites = {
  "Zahlenarten benennen": importantNumbersLearningBites,
  "Unendlichkeit": infinityLearningBites,
};

// Education Science
Map<String, List<LearningBite>> theoryEducationScienceLearningBites = {
  "Einführung": motivationLearningBites,
  "Erwartungskomponente": expectationLearningBites,
  "Wertkomponente": valueLearningBites,
  "Volition": volationLearningBites,
};

Map<String, List<LearningBite>> practiceEducationScienceLearningBites = {
  "Einführung": motivationLearningBites,
  "Erwartungskomponente": expectationLearningBites,
  "Wertkomponente": valueLearningBites,
  "Volition": volationLearningBites,
};

// Biology

// ===== Units =====
// Computer Sciene
Map<String, Map<String, List<LearningBite>>> computerLearningBites = {
  "Komponenten": componentLearningBites,
};

Map<String, Map<String, List<LearningBite>>> webLangLearningBites = {
  "HTML": htmlLearningBites,
};

// Math
Map<String, Map<String, List<LearningBite>>> numbersLearningBites = {
  "Zahlenarten": numbersNamingLearningBites,
};

// Biology

// Education Science
Map<String, Map<String, List<LearningBite>>>
    motivationEducationScienceLearningBites = {
  "Theorie": theoryEducationScienceLearningBites,
  "Praxis": practiceEducationScienceLearningBites,
};

// ===== Topics =====
// Computer Sciene
Map<String, Map<String, Map<String, List<LearningBite>>>>
    hardwareComputerScienceLearningBites = {
  "Computer": computerLearningBites,
};
Map<String, Map<String, Map<String, List<LearningBite>>>>
    softwareComputerScienceLearningBites = {
  "Websprachen": webLangLearningBites,
  "Java": {},
};
Map<String, Map<String, Map<String, List<LearningBite>>>>
    theoryComputerScienceLearningBites = {
  "Rechnerorganisation": {},
  "Datenbanken": {},
};

// Math
Map<String, Map<String, Map<String, List<LearningBite>>>>
    foundationalMathLearningBites = {
  "Zahlen": numbersLearningBites,
  "Geometrie": {},
};
Map<String, Map<String, Map<String, List<LearningBite>>>>
    advancedMathLearningBites = {
  "Analysis": {},
  "Lineare Algebra": {},
};

// Biology
Map<String, Map<String, Map<String, List<LearningBite>>>>
    foundationalBiologyLearningBites = {
  "Tiere": {},
  "Pflanzen": {},
};

// Education Science
Map<String, Map<String, Map<String, List<LearningBite>>>>
    universityEducationScienceLearningBites = {
  "Motivation": motivationEducationScienceLearningBites,
  "Lernstrategien": {},
};

// ===== Categories =====
Map<String, Map<String, Map<String, Map<String, List<LearningBite>>>>>
    computerScienceLearningBites = {
  "Hardware": hardwareComputerScienceLearningBites,
  "Software": softwareComputerScienceLearningBites,
  "Theoretische Informatik": theoryComputerScienceLearningBites,
};

Map<String, Map<String, Map<String, Map<String, List<LearningBite>>>>>
    mathLearningBites = {
  "Unter- und Mittelstufe": foundationalMathLearningBites,
  "Oberstufe": advancedMathLearningBites,
};

Map<String, Map<String, Map<String, Map<String, List<LearningBite>>>>>
    biologyLearningBites = {
  "Mittelstufe": foundationalBiologyLearningBites,
};

Map<String, Map<String, Map<String, Map<String, List<LearningBite>>>>>
    educationScienceLearningBites = {
  "Studium": universityEducationScienceLearningBites,
};

// ===== Global =====
// Subject   , Category, Topic   , Unit       , Concept  , LearningBite
// Informatik, Hardware, Computer, Komponenten, Mainboard, Mainboard - Einfach erklärt (Text)
Map<String,
        Map<String, Map<String, Map<String, Map<String, List<LearningBite>>>>>>
    learningBiteMap = {
  "Informatik": computerScienceLearningBites,
  "Mathematik": mathLearningBites,
  "Biologie": biologyLearningBites,
  "Deutsch": {},
  "Psychologie": {},
  "AGD": {},
  "Erziehungswissenschaften": educationScienceLearningBites,
};
