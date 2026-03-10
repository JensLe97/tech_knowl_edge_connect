import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String senderName;
  final String receiverId;
  final String message;
  final String type;
  final Timestamp timestamp;
  final bool blocked;

  Message(
      {required this.senderId,
      required this.senderEmail,
      required this.senderName,
      required this.receiverId,
      required this.message,
      required this.type,
      required this.timestamp,
      this.blocked = false});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      'type': type,
      'timestamp': timestamp,
      'blocked': blocked,
    };
  }
}
