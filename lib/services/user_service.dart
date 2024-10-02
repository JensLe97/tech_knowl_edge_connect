import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> blockUser(String receiverId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'blockedUsers': FieldValue.arrayUnion([receiverId]),
    });
  }

  Future<void> unblockUser(String receiverId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'blockedUsers': FieldValue.arrayRemove([receiverId]),
    });
  }

  void reportContent(
      String contentId, String uid, String type, isPostId) async {
    await FirebaseFirestore.instance.collection('reported_content').add({
      'contentId': contentId,
      'uid': uid,
      'type': type,
      'isPostId': isPostId,
    });
  }

  void reportUser(String uid) async {
    await FirebaseFirestore.instance.collection('reported_users').add({
      'uid': uid,
    });
  }
}
