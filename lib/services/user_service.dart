import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/models/report_reason.dart';

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

  void reportContent(String contentId, String uid, String type,
      isLearningMaterialId, ReportReason reason) async {
    await FirebaseFirestore.instance.collection('reported_content').add({
      'contentId': contentId,
      'uid': uid,
      'type': type,
      'isLearningMaterialId': isLearningMaterialId,
      'reason': reason.name,
      'timestamp': Timestamp.now(),
      'reporter': _firebaseAuth.currentUser!.uid,
    });
    informAdmin();
  }

  void reportUser(String uid, ReportReason reason) async {
    await FirebaseFirestore.instance.collection('reported_users').add({
      'uid': uid,
      'reason': reason.name,
      'timestamp': Timestamp.now(),
      'reporter': _firebaseAuth.currentUser!.uid,
    });
    informAdmin();
  }

  void informAdmin() async {
    try {
      await FirebaseAuth.instance.setLanguageCode("de");
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: "techknowledgeconnect@jenslemke.com",
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
