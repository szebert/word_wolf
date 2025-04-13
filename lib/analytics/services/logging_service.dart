import "package:firebase_crashlytics/firebase_crashlytics.dart";

/// {@template logging_service}
/// A service for centralized logging across the application
/// {@endtemplate}
class LoggingService {
  /// Singleton instance
  static final LoggingService _instance = LoggingService._internal();

  /// Factory constructor to return the singleton instance
  factory LoggingService() => _instance;

  /// Private constructor
  LoggingService._internal();

  /// Log an error with Crashlytics in production, or print in debug mode
  void logError(
    dynamic exception,
    StackTrace stack, {
    String? reason,
    Iterable<Object>? information,
  }) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      information: information ?? const <Object>[],
    );
  }
}
