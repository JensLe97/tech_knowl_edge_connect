import 'package:tech_knowl_edge_connect/models/learning_bite.dart';

class Concept {
  String name;
  // Montior, Processor, GPU
  List<LearningBite> learningBites;

  Concept({
    required this.name,
    required this.learningBites,
  });
}
