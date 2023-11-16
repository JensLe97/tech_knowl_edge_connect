import 'package:tech_knowl_edge_connect/models/topic.dart';

class Category {
  String name;
  // e.g. Theortische Informatik, Rechnerarchitektur, ...
  List<Topic> topics;

  Category({
    required this.name,
    required this.topics,
  });
}
