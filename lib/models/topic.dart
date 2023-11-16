import 'package:tech_knowl_edge_connect/models/unit.dart';

class Topic {
  String name;
  // e.g. Formale Sprachen, Automaten, ...
  List<Unit> units;

  Topic({
    required this.units,
    required this.name,
  });
}
