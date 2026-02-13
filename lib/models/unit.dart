import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class Unit {
  final String id;
  final String name;
  final IconData iconData;
  final String? authorId;
  final String status;

  Unit({
    required this.id,
    required this.name,
    required this.iconData,
    this.authorId,
    this.status = UserConstants.statusApproved,
  });

  factory Unit.fromMap(Map<String, dynamic> data, String id) {
    final iconMap = data['iconData'] as Map<String, dynamic>?;

    return Unit(
      id: id,
      name: data['name'] ?? '',
      iconData: UserConstants.getIconFromData(iconMap) ?? Icons.error,
      authorId: data['authorId'],
      status: data['status'] ?? UserConstants.statusApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
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
