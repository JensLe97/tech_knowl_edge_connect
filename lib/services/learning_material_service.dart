import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';
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

  Future<String> uploadData(
      XFile file, String userId, String folderId, String fullName) async {
    String extension = fullName.contains('.') ? fullName.split('.').last : '';
    extension = extension == "jpg" ? "jpeg" : extension;

    final mimeType = LearningMaterialType.getMimeType(extension);

    final ref =
        _storage.ref().child('users/$userId/folders/$folderId/$fullName');
    final uploadTask = await ref.putData(
      await file.readAsBytes(),
      SettableMetadata(contentType: mimeType),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addLearningMaterial({
    required String userId,
    required String folderId,
    required LearningMaterial material,
  }) async {
    await _firestore
        .collection('learningMaterials')
        .doc(material.id)
        .set(material.toMap());
  }

  Future<void> deleteLearningMaterial({
    required String materialId,
    required String fileUrl,
  }) async {
    // Delete from storage
    await _storage.refFromURL(fileUrl).delete();
    // Delete from Firestore
    await _firestore.collection('learningMaterials').doc(materialId).delete();
  }

  Future<void> deleteFolderAndAllMaterials({
    required String userId,
    required String folderId,
  }) async {
    // Get all materials in the learningMaterials collection for this folder
    final materialsSnapshot = await _firestore
        .collection('learningMaterials')
        .where('userId', isEqualTo: userId)
        .where('folderId', isEqualTo: folderId)
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
    // Delete all materials from learningMaterials
    for (final doc in materialsSnapshot.docs) {
      await _firestore.collection('learningMaterials').doc(doc.id).delete();
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
        .collection('learningMaterials')
        .where('userId', isEqualTo: userId)
        .where('folderId', isEqualTo: folderId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LearningMaterial.fromMap(doc.data()))
        .toList();
  }

  Stream<QuerySnapshot> getAllPublicLearningMaterials(
      {String excludeUserId = ''}) {
    return _firestore
        .collection('learningMaterials')
        .where('isPublic', isEqualTo: true)
        .where('userId', isNotEqualTo: excludeUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> likeLearningMaterial(String userId, String materialId) async {
    await FirebaseFirestore.instance.collection("Users").doc(userId).update({
      'likedLearningMaterials': FieldValue.arrayUnion([materialId]),
    });
    await _firestore.collection('learningMaterials').doc(materialId).update({
      'numberOfLikes': FieldValue.increment(1),
    });
  }

  Future<void> unlikeLearningMaterial(String userId, String materialId) async {
    await FirebaseFirestore.instance.collection("Users").doc(userId).update({
      'likedLearningMaterials': FieldValue.arrayRemove([materialId]),
    });
    await _firestore.collection('learningMaterials').doc(materialId).update({
      'numberOfLikes': FieldValue.increment(-1),
    });
  }
}
