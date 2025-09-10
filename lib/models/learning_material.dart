import 'package:cloud_firestore/cloud_firestore.dart';

class LearningMaterial {
  final String id;
  final String name;
  final String type; // e.g. pdf, png, jpg, mp4
  final String url;
  final Timestamp createdAt;
  final String folderId;

  LearningMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.folderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'createdAt': createdAt,
      'folderId': folderId,
    };
  }

  factory LearningMaterial.fromMap(Map<String, dynamic> map) {
    return LearningMaterial(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      url: map['url'],
      createdAt: map['createdAt'],
      folderId: map['folderId'],
    );
  }
}
