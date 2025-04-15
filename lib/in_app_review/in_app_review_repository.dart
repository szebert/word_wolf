import "dart:convert";

import "../storage/persistent_storage.dart";

/// {@template in_app_review_repository}
/// Repository for storing and retrieving in-app review state.
/// {@endtemplate}
class InAppReviewRepository {
  /// {@macro in_app_review_repository}
  InAppReviewRepository({
    required PersistentStorage persistentStorage,
  }) : _persistentStorage = persistentStorage;

  final PersistentStorage _persistentStorage;

  static const String _kLastReviewRequestDateKey =
      "in_app_review_last_request_date";

  /// Gets the date of the last review request.
  Future<DateTime?> getLastReviewRequestDate() async {
    try {
      final data =
          await _persistentStorage.read(key: _kLastReviewRequestDateKey);
      if (data == null || data.isEmpty) {
        return null;
      }

      final milliseconds = jsonDecode(data) as int;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    } catch (e) {
      // If there's an error reading the data, return null
      return null;
    }
  }

  /// Sets the date of the last review request.
  Future<void> setLastReviewRequestDate(DateTime date) async {
    try {
      await _persistentStorage.write(
        key: _kLastReviewRequestDateKey,
        value: jsonEncode(date.millisecondsSinceEpoch),
      );
    } catch (e) {
      // Handle storage exception
      // Since this is non-critical functionality, we can silently fail
    }
  }
}
