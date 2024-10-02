import 'package:tech_knowl_edge_connect/data/learning_bites/biology/amphibians_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/biology/birds_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/biology/fish_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/biology/mammals_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/biology/reptiles_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/biology/vertebrates_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/cpu_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/html_structure_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/html_tags_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/computer_science/mainboard_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/activation_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/advanced_strategies_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/attention_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/cognitive_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/expectation_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/elaboration_strategies_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/learntypes_styles_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/metacognition_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/metacognitive_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/motivation_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/organization_strategies_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/support_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/training_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/value_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/education_science/volition_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/math/infinity_learning_bites.dart';
import 'package:tech_knowl_edge_connect/data/learning_bites/math/numbers_naming_learning_bites.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';

// ===== Concepts =====
// Computer Science
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
  "Förderung der Lern- & Leistungsmotivation": supportLearningBites,
  "Trainings": trainingLearningBites,
};

Map<String, List<LearningBite>> foundationEducationScienceLearningBites = {
  "Kognitive Strategien": cognitiveLearningBites,
  "Metakognitive Strategien": metacognitiveLearningBites,
  "Metakognition": metacognitionLearningBites,
  "Lerntypen und Lernstile": learnTypesStylesLearningBites,
};

Map<String, List<LearningBite>> advancedEducationScienceLearningBites = {
  "Fortgeschrittene Strategien": advancedStrategiesLearningBites,
  "Aufmerksamkeit und Lernen": attentionStrategiesLearningBites,
  "Lernstrategie: Vorwissen aktivieren": activationStrategiesLearningBites,
  "Elaborationsstrategien": elaborationStrategiesLearningBites,
  "Organisationsstrategien": organizationStrategiesLearningBites,
};

// Biology
Map<String, List<LearningBite>> vertebratesLearningBites = {
  "Einführung": vertebratesIntroLearningBites,
  "Fische": fishLearningBites,
  "Amphibien": amphibiansLearningBites,
  "Reptilien": reptilesLearningBites,
  "Säugetiere": mammalsLearningBites,
  "Vögel": birdsLearningBites,
};

// ===== Units =====
// Computer Science
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
Map<String, Map<String, List<LearningBite>>> animalsLearningBites = {
  "Wirbeltiere": vertebratesLearningBites,
  // "Wirbellose Tiere": {},
};

// Education Science
Map<String, Map<String, List<LearningBite>>>
    motivationEducationScienceLearningBites = {
  "Theorie": theoryEducationScienceLearningBites,
  "Praxis": practiceEducationScienceLearningBites,
};
Map<String, Map<String, List<LearningBite>>>
    learningStrategiesEducationScienceLearningBites = {
  "Grundlagen": foundationEducationScienceLearningBites,
  "Vertiefung": advancedEducationScienceLearningBites,
};

// ===== Topics =====
// Computer Science
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
  "Tiere": animalsLearningBites,
  "Pflanzen": {},
};

// Education Science
Map<String, Map<String, Map<String, List<LearningBite>>>>
    universityEducationScienceLearningBites = {
  "Motivation": motivationEducationScienceLearningBites,
  "Lernstrategien": learningStrategiesEducationScienceLearningBites,
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
  "Studium": foundationalBiologyLearningBites,
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
