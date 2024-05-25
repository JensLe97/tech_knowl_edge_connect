import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getLastInfos(
      String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .snapshots();
  }

  Stream<QuerySnapshot> getLastMessages() {
    return _firebaseFirestore
        .collection('chat_rooms')
        .where('users', arrayContains: _firebaseAuth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String receiverId, String message,
      {bool fromAI = false, String type = "text"}) async {
    final String currentUserId =
        fromAI ? "aitech" : _firebaseAuth.currentUser!.uid;
    receiverId = fromAI ? _firebaseAuth.currentUser!.uid : receiverId;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final String currentUserName =
        _firebaseAuth.currentUser!.displayName.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      senderName: currentUserName,
      receiverId: receiverId,
      message: message,
      type: type,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    if (receiverId == "aitech") {
      return;
    }

    DocumentSnapshot<Map<String, dynamic>> chatRoomData =
        await _firebaseFirestore.collection('chat_rooms').doc(chatRoomId).get();

    int unreadTo = 0;
    int unreadFrom = 0;
    if (chatRoomData.data() != null) {
      unreadTo = chatRoomData.data()!['unreadTo'] ?? 0;
      unreadFrom = chatRoomData.data()!['unreadFrom'] ?? 0;
    }
    if (ids.first == currentUserId) {
      // current user is the first user in the chat room (the sender)
      unreadTo++;
    } else {
      // current user is the second user in the chat room (the receiver)
      unreadFrom++;
    }

    await _firebaseFirestore.collection('chat_rooms').doc(chatRoomId).set({
      'lastMessage': message,
      'type': type,
      'lastTimestamp': timestamp,
      'unreadFrom': unreadFrom,
      'unreadTo': unreadTo,
    });
  }
}
