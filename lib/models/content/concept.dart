import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class Concept {
  final String id;
  final String name;
  final String? authorId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Concept({
    required this.id,
    required this.name,
    this.authorId,
    this.status = UserConstants.statusApproved,
    this.createdAt,
    this.updatedAt,
  });

  factory Concept.fromMap(Map<String, dynamic> data, String id) {
    final createdTs = data['createdAt'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;
    return Concept(
      id: id,
      name: data['name'] ?? '',
      authorId: data['authorId'],
      status: data['status'] ?? UserConstants.statusApproved,
      createdAt: createdTs?.toDate(),
      updatedAt: updatedTs?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'authorId': authorId,
      'status': status,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}
