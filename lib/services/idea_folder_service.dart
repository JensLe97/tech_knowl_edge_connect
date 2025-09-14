import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/models/idea_folder.dart';

class IdeaFolderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleFolderPublic({
    required String userId,
    required String folderId,
    required bool isPublic,
  }) async {
    // Update the folder's isPublic field
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .update({'isPublic': isPublic});

    // Update isPublic for all learningMaterials in this folder for this user
    final materialsSnapshot = await _firestore
        .collection('learningMaterials')
        .where('userId', isEqualTo: userId)
        .where('folderId', isEqualTo: folderId)
        .get();
    for (final doc in materialsSnapshot.docs) {
      await _firestore
          .collection('learningMaterials')
          .doc(doc.id)
          .update({'isPublic': isPublic});
    }
  }

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
              userId: doc['userId'],
              isPublic: doc['isPublic'] ?? true,
            ))
        .toList();
  }
}
