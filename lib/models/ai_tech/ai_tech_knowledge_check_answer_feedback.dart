class AiTechKnowledgeCheckAnswerFeedback {
  final String transcript;
  final String feedback;
  final bool isCorrect;
  final String correctAnswer;
  final String nextAction;
  final bool needsFollowUp;
  final String followUpQuestion;

  const AiTechKnowledgeCheckAnswerFeedback({
    required this.transcript,
    required this.feedback,
    required this.isCorrect,
    required this.correctAnswer,
    required this.nextAction,
    required this.needsFollowUp,
    required this.followUpQuestion,
  });

  factory AiTechKnowledgeCheckAnswerFeedback.fromMap(Map<String, dynamic> map) {
    return AiTechKnowledgeCheckAnswerFeedback(
      transcript: (map['transcript'] ?? '').toString(),
      feedback: (map['feedback'] ?? '').toString(),
      isCorrect: map['isCorrect'] == true,
      correctAnswer: (map['correctAnswer'] ?? '').toString(),
      nextAction: (map['nextAction'] ?? '').toString(),
      needsFollowUp: map['needsFollowUp'] == true,
      followUpQuestion: (map['followUpQuestion'] ?? '').toString(),
    );
  }
}
