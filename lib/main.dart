import "package:shared_preferences/shared_preferences.dart";

import "analytics_repository/analytics_repository.dart";
import "app/app.dart";
import "bootstrap.dart";
import "feedback_repository/feedback_repository.dart";
import "storage/persistent_storage.dart";

void main() async {
  await bootstrap(
    (
      final SharedPreferences sharedPreferences,
      final AnalyticsRepository analyticsRepository,
    ) async {
      final PersistentStorage persistentStorage = PersistentStorage(
        sharedPreferences: sharedPreferences,
      );

      final FeedbackRepository feedbackRepository = FeedbackRepository(
        storage: FeedbackStorage(storage: persistentStorage),
      );

      return App(
        feedbackRepository: feedbackRepository,
        analyticsRepository: analyticsRepository,
        persistentStorage: persistentStorage,
      );
    },
  );
}
