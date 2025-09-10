import 'package:cloud_firestore/cloud_firestore.dart';

class IdeaFolder {
  final String id;
  final String name;
  final String description;
  final List<String> ideaPostIds;
  final Timestamp timestamp;
  final bool isPublic;

  IdeaFolder(
      {required this.id,
      required this.name,
      required this.description,
      required this.ideaPostIds,
      required this.timestamp,
      this.isPublic = true});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ideaPostIds': ideaPostIds,
      'timestamp': timestamp,
      'isPublic': isPublic,
    };
  }
}
