import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/idea_post.dart';

class IdeaPostsService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPosts() {
    return _firebaseFirestore
        .collection('idea_posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> getUserName() {
    return _firebaseFirestore
        .collection('Users')
        .where('uid', isEqualTo: _firebaseAuth.currentUser!.uid)
        .snapshots()
        .first
        .then((value) => value.docs.first.get('username'));
  }

  Future<void> uploadPost(String imageUrl, String caption,
      {String type = "image"}) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    IdeaPostItem newIdeaPost = IdeaPostItem(
      uid: currentUserId,
      username: await getUserName(),
      caption: caption,
      numberOfLikes: 0,
      numberOfComments: 0,
      numberOfShares: 0,
      content: imageUrl,
      type: type,
      timestamp: timestamp,
    );

    await _firebaseFirestore.collection('idea_posts').add(newIdeaPost.toMap());
  }

  Future<void> likePost(String postId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'likedPosts': FieldValue.arrayUnion([postId]),
    });
    await _firebaseFirestore.collection('idea_posts').doc(postId).update({
      'numberOfLikes': FieldValue.increment(1),
    });
  }

  Future<void> unlikePost(String postId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'likedPosts': FieldValue.arrayRemove([postId]),
    });
    await _firebaseFirestore.collection('idea_posts').doc(postId).update({
      'numberOfLikes': FieldValue.increment(-1),
    });
  }
}
