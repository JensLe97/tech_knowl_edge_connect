import 'package:cloud_firestore/cloud_firestore.dart';

class IdeaPostItem {
  final String uid;
  final String username;
  final String caption;
  final String content;
  final String type;
  final int numberOfLikes;
  final int numberOfComments;
  final int numberOfShares;
  final Timestamp timestamp;

  IdeaPostItem(
      {required this.uid,
      required this.username,
      required this.caption,
      required this.content,
      required this.type,
      required this.numberOfLikes,
      required this.numberOfComments,
      required this.numberOfShares,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'caption': caption,
      'content': content,
      'type': type,
      'numberOfLikes': numberOfLikes,
      'numberOfComments': numberOfComments,
      'numberOfShares': numberOfShares,
      'timestamp': timestamp,
    };
  }
}
