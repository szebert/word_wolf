import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../l10n/l10n.dart";
import "../analytics/analytics_bloc.dart";
import "../analytics_repository/analytics_repository.dart";
import "../app_ui/app_config.dart";
import "../app_ui/app_theme.dart";
import "../feedback_repository/feedback_repository.dart";
import "../home_page.dart";
import "../settings/settings_bloc.dart";
import "../theme/theme_mode_bloc.dart";

class App extends StatelessWidget {
  const App({
    required final FeedbackRepository feedbackRepository,
    required final AnalyticsRepository analyticsRepository,
    super.key,
  })  : _feedbackRepository = feedbackRepository,
        _analyticsRepository = analyticsRepository;

  final FeedbackRepository _feedbackRepository;
  final AnalyticsRepository _analyticsRepository;

  @override
  Widget build(final BuildContext context) {
    // Initialize AppUiConfig with sound settings
    AppConfig.initialize(_feedbackRepository.fetchFeedbackSettings);

    return MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<FeedbackRepository>.value(
          value: _feedbackRepository,
        ),
        RepositoryProvider<AnalyticsRepository>.value(
          value: _analyticsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<StateStreamableSource<Object?>>>[
          BlocProvider<ThemeModeBloc>(create: (final _) => ThemeModeBloc()),
          BlocProvider<AnalyticsBloc>(
            create: (final context) => AnalyticsBloc(
              analyticsRepository: _analyticsRepository,
            ),
            lazy: false,
          ),
          BlocProvider<SettingsBloc>(
            create: (final context) => SettingsBloc(
              feedbackRepository: context.read<FeedbackRepository>(),
            ),
            lazy: false,
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ThemeModeBloc, ThemeMode>(
      builder: (final context, final themeMode) {
        return Builder(
          builder: (final BuildContext context) {
            final double textScale = context.select(
              (final SettingsBloc bloc) => bloc.state.textScale,
            );

            return MaterialApp(
              builder: (final context, final child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                );
              },
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}
