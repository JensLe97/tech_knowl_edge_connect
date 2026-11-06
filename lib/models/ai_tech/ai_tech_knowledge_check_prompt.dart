class AiTechKnowledgeCheckPrompt {
  final String prompt;
  final String followUp;
  final String assessment;

  const AiTechKnowledgeCheckPrompt({
    required this.prompt,
    this.followUp = '',
    this.assessment = '',
  });

  factory AiTechKnowledgeCheckPrompt.fromMap(Map<String, dynamic> map) {
    return AiTechKnowledgeCheckPrompt(
      prompt: (map['prompt'] ?? map['question'] ?? '').toString(),
      followUp: (map['followUp'] ?? map['follow_up'] ?? '').toString(),
      assessment: (map['assessment'] ?? map['summary'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'prompt': prompt,
    if (followUp.isNotEmpty) 'followUp': followUp,
    if (assessment.isNotEmpty) 'assessment': assessment,
  };
}
