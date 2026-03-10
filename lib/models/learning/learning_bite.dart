import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class LearningBite {
  final String id;
  final String name;
  final String type;
  final List<String> content;
  final bool completed;
  final IconData iconData;
  final String? authorId;
  final String
      status; // 'private', 'pending', UserConstants.statusApproved, 'rejected'

  LearningBite({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    this.completed = false,
    this.iconData = Icons.book,
    this.authorId,
    this.status = UserConstants
        .statusApproved, // Default to approved for existing static content
  });

  factory LearningBite.fromMap(Map<String, dynamic> data, String id) {
    final iconMap = data['iconData'] as Map<String, dynamic>?;

    return LearningBite(
      id: id,
      name: data['title'] ?? '',
      type: data['type'] ?? 'lesson',
      content: List<String>.from(data['content'] ?? []),
      completed: data['completed'] ?? false,
      iconData: UserConstants.getIconFromData(iconMap) ?? Icons.book,
      authorId: data['authorId'],
      status: data['status'] ?? UserConstants.statusApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': name,
      'type': type,
      'content': content,
      'completed': completed,
      'iconData': {
        'codePoint': iconData.codePoint,
        'fontFamily': iconData.fontFamily,
        'fontPackage': iconData.fontPackage,
      },
      'authorId': authorId,
      'status': status,
    };
  }
}
