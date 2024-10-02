import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/idea_post_view.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/services/idea_posts_service.dart';

class IdeasPage extends StatefulWidget {
  const IdeasPage({super.key});

  @override
  State<IdeasPage> createState() => _IdeasPageState();
}

class _IdeasPageState extends State<IdeasPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final IdeaPostsService _ideaPostsService = IdeaPostsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: _buildIdeaPostViewList());
  }

  Widget _buildIdeaPostViewList() {
    return StreamBuilder<QuerySnapshot>(
        stream: _ideaPostsService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return PageView(
                scrollDirection: Axis.vertical,
                children: snapshot.data!.docs
                    .where((doc) => !blockedUsers.contains(doc['uid']))
                    .map<Widget>((docs) => _buildIdeaPostViewItem(docs))
                    .toList());
          } else {
            return const Text("Keine Posts vorhanden.");
          }
        });
  }

  Widget _buildIdeaPostViewItem(DocumentSnapshot document) {
    Map<String, dynamic> docData = document.data()! as Map<String, dynamic>;
    return IdeaPostViewItem(
      postId: document.id,
      username: docData['username'],
      uid: docData['uid'],
      caption: docData['caption'],
      numberOfLikes: docData['numberOfLikes'],
      numberOfComments: docData['numberOfComments'],
      numberOfShares: docData['numberOfShares'],
      content: docData['content'],
      type: docData['type'],
    );
  }
}
