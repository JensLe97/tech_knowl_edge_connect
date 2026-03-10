import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class Subject {
  final String id;
  final String name;
  final Color color;
  final IconData iconData;
  final String? authorId;
  final String status;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.iconData,
    this.authorId,
    this.status = UserConstants.statusApproved,
  });

  factory Subject.fromMap(Map<String, dynamic> data, String id) {
    final iconMap = data['iconData'] as Map<String, dynamic>?;

    return Subject(
      id: id,
      name: data['name'] ?? '',
      color: Color(data['color'] ?? 0xFF000000),
      iconData: UserConstants.getIconFromData(iconMap) ?? Icons.error,
      authorId: data['authorId'],
      status: data['status'] ?? UserConstants.statusApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color.toARGB32(),
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
