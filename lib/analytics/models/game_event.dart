import "firebase_analytics_event.dart";

/// {@template game_started_event}
/// Tracked when a game is started.
/// {@endtemplate}
class GameStartedEvent extends FirebaseAnalyticsEvent {
  /// {@macro game_started_event}
  GameStartedEvent({
    required int playerCount,
    required int wolfCount,
    required bool randomizeWolfCount,
    required String category,
    required bool isOnline,
    required double wordPairSimilarity,
    required bool wolfRevengeEnabled,
    required int discussionTimeInSeconds,
    required String citizenWord,
    required String wolfWord,
    required int icebreakerCount,
    required bool categorySelected,
    required bool autoAssignWolves,
  }) : super(
          "game_started",
          properties: {
            // word pair info
            "category": category,
            "citizen_word": citizenWord,
            "wolf_word": wolfWord,
            "icebreaker_count": icebreakerCount,
            "is_online": isOnline,
            // game settings
            "category_selected": categorySelected,
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
