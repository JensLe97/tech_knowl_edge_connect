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
        .where(Filter.or(Filter('blocked', isEqualTo: false),
            Filter('senderId', isEqualTo: userId)))
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<bool> isBlocked(String userId, String otherUserId) async {
    var documentSnapshot =
        await _firebaseFirestore.collection('Users').doc(otherUserId).get();

    if (documentSnapshot.data() != null) {
      List<dynamic> blockedUsers =
          documentSnapshot.data()!['blockedUsers'] ?? [];
      if (blockedUsers.contains(userId)) {
        return true;
      }
    }

    return false;
  }

  Future<void> sendMessage(String receiverId, String message,
      {bool fromAI = false, String type = "text"}) async {
    final String currentUserId =
        fromAI ? "aitech" : _firebaseAuth.currentUser!.uid;
    receiverId = fromAI ? _firebaseAuth.currentUser!.uid : receiverId;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final String currentUserName =
        _firebaseAuth.currentUser!.displayName ?? "Anonymer User";
    final Timestamp timestamp = Timestamp.now();

    // check if the other user has blocked the current user
    final bool isUserBlocked = await isBlocked(currentUserId, receiverId);

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      senderName: currentUserName,
      receiverId: receiverId,
      message: message,
      type: type,
      timestamp: timestamp,
      blocked: isUserBlocked,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    if (receiverId == "aitech" || fromAI) {
      return;
    }

    DocumentSnapshot<Map<String, dynamic>> chatRoomData =
        await _firebaseFirestore.collection('chat_rooms').doc(chatRoomId).get();

    int unreadTo = 0;
    int unreadFrom = 0;
    String lastUnblockedMessage = message;
    if (chatRoomData.data() != null) {
      unreadTo = chatRoomData.data()!['unreadTo'] ?? 0;
      unreadFrom = chatRoomData.data()!['unreadFrom'] ?? 0;
      if (isUserBlocked) {
        lastUnblockedMessage =
            chatRoomData.data()!['lastUnblockedMessage'] ?? message;
      }
    }
    if (!isUserBlocked) {
      if (ids.first == currentUserId) {
        // current user is the first user in the chat room (the sender)
        unreadTo++;
      } else {
        // current user is the second user in the chat room (the receiver)
        unreadFrom++;
      }
    }

    await _firebaseFirestore.collection('chat_rooms').doc(chatRoomId).set({
      'lastMessage': message,
      'lastUnblockedMessage': lastUnblockedMessage,
      'lastSenderId': currentUserId,
      'isBlocked': isUserBlocked,
      'type': type,
      'lastTimestamp': timestamp,
      'unreadFrom': unreadFrom,
      'unreadTo': unreadTo,
    });
  }
}
