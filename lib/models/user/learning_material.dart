import 'package:cloud_firestore/cloud_firestore.dart';

class LearningMaterial {
  final String id;
  final String name;
  final String type; // e.g. pdf, png, jpg, mp4
  final String url;
  final Timestamp createdAt;
  final String userId;
  final String userName;
  final String folderId;
  final bool isPublic;
  final int numberOfLikes;

  LearningMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.folderId,
    this.isPublic = true,
    this.numberOfLikes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'createdAt': createdAt,
      'userId': userId,
      'userName': userName,
      'folderId': folderId,
      'isPublic': isPublic,
      'numberOfLikes': numberOfLikes,
    };
  }

  factory LearningMaterial.fromMap(Map<String, dynamic> map) {
    return LearningMaterial(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      url: map['url'],
      createdAt: map['createdAt'],
      userId: map['userId'],
      userName: map['userName'],
      folderId: map['folderId'],
      isPublic: map['isPublic'] ?? true,
      numberOfLikes: map['numberOfLikes'] ?? 0,
    );
  }
}
