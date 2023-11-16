import 'package:tech_knowl_edge_connect/data/units/biology/animals_units.dart';
import 'package:tech_knowl_edge_connect/data/units/biology/plants_units.dart';
import 'package:tech_knowl_edge_connect/data/units/computer_science/computer_organization_units.dart';
import 'package:tech_knowl_edge_connect/data/units/computer_science/computer_units.dart';
import 'package:tech_knowl_edge_connect/data/units/computer_science/data_base_units.dart';
import 'package:tech_knowl_edge_connect/data/units/computer_science/java_units.dart';
import 'package:tech_knowl_edge_connect/data/units/computer_science/web_lang_units.dart';
import 'package:tech_knowl_edge_connect/data/units/math/analysis_units.dart';
import 'package:tech_knowl_edge_connect/data/units/math/geometry_units.dart';
import 'package:tech_knowl_edge_connect/data/units/math/linear_algebra_units.dart';
import 'package:tech_knowl_edge_connect/data/units/math/numbers_units.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';

// ===== Topics =====
// Computer Sciene
Map<String, List<Unit>> hardwareComputerScienceUnits = {
  "Computer": computerUnits,
};
Map<String, List<Unit>> softwareComputerScienceUnits = {
  "Websprachen": webLangUnits,
  "Java": javaUnits,
};
Map<String, List<Unit>> theoryComputerScienceUnits = {
  "Rechnerorganisation": computerOrganizationUnits,
  "Datenbanken": dataBaseUnits,
};

// Math
Map<String, List<Unit>> foundationalMathUnits = {
  "Zahlen": numbersUnits,
  "Geometrie": geometryUnits
};
Map<String, List<Unit>> advancedMathUnits = {
  "Analysis": analysisUnits,
  "Lineare Algebra": linearAlgebraUnits,
};

// Biology
Map<String, List<Unit>> foundationalBiologyUnits = {
  "Tiere": animalsUnits,
  "Pflanzen": plantsUnits,
};

// ===== Categories =====
Map<String, Map<String, List<Unit>>> computerScienceUnits = {
  "Hardware": hardwareComputerScienceUnits,
  "Software": softwareComputerScienceUnits,
  "Theoretische Informatik": theoryComputerScienceUnits,
};

Map<String, Map<String, List<Unit>>> mathUnits = {
  "Unter- und Mittelstufe": foundationalMathUnits,
  "Oberstufe": advancedMathUnits,
};

Map<String, Map<String, List<Unit>>> biologyUnits = {
  "Mittelstufe": foundationalBiologyUnits,
};

// ===== Global =====
// Informatik, Hardware, Computer, Komponenten
Map<String, Map<String, Map<String, List<Unit>>>> unitMap = {
  "Informatik": computerScienceUnits,
  "Mathematik": mathUnits,
  "Biologie": biologyUnits,
};
