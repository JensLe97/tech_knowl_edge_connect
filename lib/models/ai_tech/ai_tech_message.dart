import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for AI Tech chat message
class AiTechMessage {
  final String role; // user, assistant, system, agent
  final String text;
  final DateTime ts;
  final String type;
  final String journeyId;
  final Map<String, dynamic>? meta;

  AiTechMessage({
    required this.role,
    required this.text,
    required this.ts,
    required this.type,
    this.journeyId = '',
    this.meta,
  });

  Map<String, dynamic> toMap() => {
        'role': role,
        'text': text,
        'ts': ts,
        'type': type,
        'journeyId': journeyId,
        'meta': meta,
      };

  factory AiTechMessage.fromMap(Map<String, dynamic> map) => AiTechMessage(
        role: (map['role'] ?? 'user').toString(),
        text: (map['text'] ?? '').toString(),
        ts: map['ts'] is Timestamp
            ? (map['ts'] as Timestamp).toDate()
            : (map['ts'] is DateTime
                ? map['ts'] as DateTime
                : DateTime.fromMillisecondsSinceEpoch(0)),
        type: map['type'] ?? 'default',
        journeyId: map['journeyId'] ?? '',
        meta: map['meta'],
      );
}
