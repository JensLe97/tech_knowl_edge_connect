import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class Topic {
  final String id;
  final String name;
  final String? authorId;
  final String status;
  final DateTime? createdAt;

  Topic({
    required this.id,
    required this.name,
    this.authorId,
    this.status = UserConstants.statusApproved,
    this.createdAt,
  });

  factory Topic.fromMap(Map<String, dynamic> data, String id) {
    final createdTs = data['createdAt'] as Timestamp?;
    return Topic(
      id: id,
      name: data['name'] ?? '',
      authorId: data['authorId'],
      status: data['status'] ?? UserConstants.statusApproved,
      createdAt: createdTs?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'authorId': authorId,
      'status': status,
    };
  }
}
