import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class Category {
  final String id;
  final String name;
  final String? authorId;
  final String status;

  Category({
    required this.id,
    required this.name,
    this.authorId,
    this.status = UserConstants.statusApproved,
  });

  factory Category.fromMap(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      authorId: data['authorId'],
      status: data['status'] ?? UserConstants.statusApproved,
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
