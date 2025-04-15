import "firebase_analytics_event.dart";

/// {@template game_started_event}
/// Tracked when a game is started.
/// {@endtemplate}
class GameStartedEvent extends FirebaseAnalyticsEvent {
  /// {@macro game_started_event}
  GameStartedEvent({
    // word pair info
    required String category,
    required String citizenWord,
    required String wolfWord,
    required int icebreakerCount,
    required double wordPairSimilarity,
    required String wordGeneration,
    // game settings
    required String categoryEnabled,
    required int discussionTimeInSeconds,
    required int playerCount,
    required int wolfCount,
    required String randomizeWolfCount,
    required String autoAssignWolves,
    required String wolfRevengeEnabled,
  }) : super(
          "game_started",
          properties: {
            // word pair info
            "category": category,
            "citizen_word": citizenWord,
            "wolf_word": wolfWord,
            "icebreaker_count": icebreakerCount,
            "word_generation": wordGeneration,
            // game settings
            "category_enabled": categoryEnabled,
            "player_count": playerCount,
            "wolf_count": wolfCount,
            "randomize_wolf_count": randomizeWolfCount,
            "auto_assign_wolves": autoAssignWolves,
            "word_pair_similarity": wordPairSimilarity,
            "wolf_revenge_enabled": wolfRevengeEnabled,
            "discussion_time_seconds": discussionTimeInSeconds,
          },
        );
}
