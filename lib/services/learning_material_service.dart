import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/models/learning_material.dart';

class LearningMaterialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(
      File file, String userId, String folderId, String fileName) async {
    final ref =
        _storage.ref().child('users/$userId/folders/$folderId/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addLearningMaterial({
    required String userId,
    required String folderId,
    required LearningMaterial material,
  }) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .collection('materials')
        .doc(material.id)
        .set(material.toMap());
  }

  Future<void> deleteLearningMaterial({
    required String userId,
    required String folderId,
    required String materialId,
    required String fileUrl,
  }) async {
    // Delete from storage
    await _storage.refFromURL(fileUrl).delete();
    // Delete from Firestore
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .collection('materials')
        .doc(materialId)
        .delete();
  }

  Future<void> deleteFolderAndAllMaterials({
    required String userId,
    required String folderId,
  }) async {
    // Get all materials in the folder
    final materialsSnapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .collection('materials')
        .get();
    // Delete all files from storage
    for (final doc in materialsSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('url')) {
        try {
          await _storage.refFromURL(data['url']).delete();
        } catch (_) {}
      }
    }
    // Delete all materials from Firestore
    for (final doc in materialsSnapshot.docs) {
      await doc.reference.delete();
    }
    // Delete the folder document itself
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .delete();
  }

  Future<List<LearningMaterial>> getLearningMaterials({
    required String userId,
    required String folderId,
  }) async {
    final snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('ideaFolders')
        .doc(folderId)
        .collection('materials')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LearningMaterial.fromMap(doc.data()))
        .toList();
  }
}
