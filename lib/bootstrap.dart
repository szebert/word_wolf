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

import "analytics_repository/analytics_repository.dart";
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
      WidgetsFlutterBinding.ensureInitialized();

      // Set preferred orientations to portrait only (normal and upside down)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );
      final analyticsRepository =
          AnalyticsRepository(FirebaseAnalytics.instance);

      unawaited(MobileAds.instance.initialize());

      final blocObserver = AppBlocObserver(
        analyticsRepository: analyticsRepository,
      );
      Bloc.observer = blocObserver;

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

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      final sharedPreferences = await SharedPreferences.getInstance();

      // Initialize ThemeModeBloc before running the app
      final themeModeBloc = ThemeModeBloc();

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
    (_, __) {},
  );
}
