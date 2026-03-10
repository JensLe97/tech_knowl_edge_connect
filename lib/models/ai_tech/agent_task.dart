/// Skills available within [LearningJourneyAgent].
enum JourneySkill { create, update, addBite }

/// Skills available within [FeedbackAgent].
enum FeedbackSkill { giveFeedback, recommend }

/// A typed routing decision produced by [AnalyzeAgent].
///
/// Using a [sealed] class hierarchy instead of a flat enum makes every routing
/// decision carry both the target agent and the specific skill to invoke within
/// it. Dart's exhaustive [switch] ensures new intents cannot go unhandled.
sealed class AgentIntent {
  const AgentIntent();

  /// Short identifier saved in the Firestore `type` field of chat messages.
  String get storageKey;
}

// ---------------------------------------------------------------------------
// LearningJourneyAgent intents
// ---------------------------------------------------------------------------

/// Route to [LearningJourneyAgent] with the given [skill].
final class JourneyIntent extends AgentIntent {
  const JourneyIntent(this.skill);
  final JourneySkill skill;

  @override
  String get storageKey => 'journey.${skill.name}';
}

// ---------------------------------------------------------------------------
// FeedbackAgent intents
// ---------------------------------------------------------------------------

/// Route to [FeedbackAgent] with the given [skill].
final class FeedbackIntent extends AgentIntent {
  const FeedbackIntent(this.skill);
  final FeedbackSkill skill;

  @override
  String get storageKey => 'feedback.${skill.name}';
}

// ---------------------------------------------------------------------------
// Single-skill agent intents
// ---------------------------------------------------------------------------

final class ExplainIntent extends AgentIntent {
  const ExplainIntent();
  @override
  String get storageKey => 'explain';
}

final class HintIntent extends AgentIntent {
  const HintIntent();
  @override
  String get storageKey => 'hint';
}

final class QuizIntent extends AgentIntent {
  const QuizIntent();
  @override
  String get storageKey => 'quiz';
}

final class ReviewIntent extends AgentIntent {
  const ReviewIntent();
  @override
  String get storageKey => 'review';
}

final class GeneralIntent extends AgentIntent {
  const GeneralIntent();
  @override
  String get storageKey => 'general';
}
