import "dart:async";

import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_app_check/firebase_app_check.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "analytics/analytics.dart";
import "app/app_bloc_observer.dart";
import "firebase_options.dart";
import "theme/theme_mode_bloc.dart";

typedef AppBuilder = Future<Widget> Function(
  SharedPreferences sharedPreferences,
  AnalyticsRepository analyticsRepository,
);

Future<void> bootstrap(final builder) async {
  await runZonedGuarded<Future<void>>(
    () async {
      // Initialize Widgets
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase App Check
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
      );

      // Initialize Firebase Analytics
      final analyticsRepository =
          AnalyticsRepository(FirebaseAnalytics.instance);

      // Initialize Mobile Ads
      unawaited(MobileAds.instance.initialize());

      // Initialize App Bloc Observer
      final blocObserver = AppBlocObserver(
        analyticsRepository: analyticsRepository,
      );
      Bloc.observer = blocObserver;

      // Initialize Hydrated Storage
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory(
                (await getApplicationSupportDirectory()).path,
              ),
      );
      if (kDebugMode) {
        await HydratedBloc.storage.clear();
      }

      // Initialize Firebase Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Configure crash handling for Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        LoggingService().logError(
          details.exception,
          details.stack ?? StackTrace.current,
          reason: "Flutter error: ${details.library}",
          information: [
            "Context: ${details.context}",
            "Summary: ${details.summary}",
          ],
        );
      };

      // Initialize Shared Preferences
      final sharedPreferences = await SharedPreferences.getInstance();

      // Set preferred orientations to portrait only (normal and upside down)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Initialize ThemeModeBloc before running the app
      final themeModeBloc = ThemeModeBloc();

      // Run the app
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: themeModeBloc),
          ],
          child: await builder(
            sharedPreferences,
            analyticsRepository,
          ),
        ),
      );
    },
    (error, stack) {
      // Handle uncaught async errors with Crashlytics
      LoggingService().logError(
        error,
        stack,
        reason: "Uncaught zone error",
      );
    },
  );
}
