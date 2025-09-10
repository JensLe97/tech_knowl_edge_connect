import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/models/idea_folder.dart';

class IdeaFolderService {
  Future<void> toggleFolderPublic({
    required String userId,
    required String folderId,
    required bool isPublic,
  }) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .update({'isPublic': isPublic});
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFolder({
    required String userId,
    required IdeaFolder folder,
  }) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folder.id)
        .set(folder.toMap());
  }

  Future<List<IdeaFolder>> getFolders({
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => IdeaFolder(
              id: doc['id'] ?? doc.id,
              name: doc['name'],
              description: doc['description'],
              ideaPostIds: List<String>.from(doc['ideaPostIds'] ?? []),
              timestamp: doc['timestamp'],
              isPublic: doc['isPublic'] ?? true,
            ))
        .toList();
  }
}
