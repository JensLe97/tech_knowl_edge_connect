import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_type.dart';

/// Firestore model for AI Tech session
class AiTechSession {
  final String sessionId;
  final String userId;
  final DateTime startAt;
  final DateTime? endAt;
  final DateTime lastTimestamp;
  final SessionType sessionType;
  final String unit;

  AiTechSession({
    required this.sessionId,
    required this.userId,
    required this.startAt,
    this.endAt,
    required this.lastTimestamp,
    required this.sessionType,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'userId': userId,
        'startAt': startAt,
        'endAt': endAt,
        'lastTimestamp': lastTimestamp,
        'sessionType': sessionType.name,
        'unit': unit,
      };

  factory AiTechSession.fromMap(Map<String, dynamic> map) => AiTechSession(
        sessionId: map['sessionId'],
        userId: map['userId'],
        startAt: (map['startAt'] as Timestamp).toDate(),
        endAt:
            map['endAt'] != null ? (map['endAt'] as Timestamp).toDate() : null,
        lastTimestamp: map['lastTimestamp'] != null
            ? (map['lastTimestamp'] as Timestamp).toDate()
            : (map['startAt'] as Timestamp).toDate(),
        sessionType: SessionType.values.firstWhere(
            (e) => e.name == map['sessionType'],
            orElse: () => SessionType.study),
        unit: map['unit'] ?? '',
      );
}
