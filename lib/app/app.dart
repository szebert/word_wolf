import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../analytics/analytics_bloc.dart";
import "../analytics_repository/analytics_repository.dart";
import "../api/api_service_provider.dart";
import "../api/bloc/api_config_bloc.dart";
import "../api/repository/api_config_repository.dart";
import "../api/services/ai_service_manager.dart";
import "../app_ui/app_config.dart";
import "../app_ui/app_theme.dart";
import "../category/bloc/category_bloc.dart";
import "../category/repository/category_repository.dart";
import "../feedback_repository/feedback_repository.dart";
import "../game/bloc/game_bloc.dart";
import "../game/repository/game_repository.dart";
import "../game/repository/player_repository.dart";
import "../game/services/used_words_storage.dart";
import "../game/services/word_pair_service.dart";
import "../home/home_page.dart";
import "../l10n/l10n.dart";
import "../settings/settings_bloc.dart";
import "../storage/persistent_storage.dart";
import "../theme/theme_mode_bloc.dart";
import "./app_bloc.dart";
import "./app_repository.dart";

class App extends StatelessWidget {
  const App({
    required final FeedbackRepository feedbackRepository,
    required final AnalyticsRepository analyticsRepository,
    required final PersistentStorage persistentStorage,
    super.key,
  })  : _feedbackRepository = feedbackRepository,
        _analyticsRepository = analyticsRepository,
        _persistentStorage = persistentStorage;

  final FeedbackRepository _feedbackRepository;
  final AnalyticsRepository _analyticsRepository;
  final PersistentStorage _persistentStorage;

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
        RepositoryProvider<AppRepository>(
          create: (context) => AppRepository(
            persistentStorage: _persistentStorage,
          ),
        ),
        RepositoryProvider<PlayerRepository>(
          create: (context) => PlayerRepository(
            persistentStorage: _persistentStorage,
          ),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(
            persistentStorage: _persistentStorage,
          ),
        ),
        RepositoryProvider<GameRepository>(
          create: (context) => GameRepository(
            persistentStorage: _persistentStorage,
          ),
        ),
        RepositoryProvider<UsedWordsStorage>(
          create: (context) => UsedWordsStorage(
            storage: _persistentStorage,
          ),
        ),
        RepositoryProvider<APIConfigRepository>(
          create: (context) => APIConfigRepository(
            persistentStorage: _persistentStorage,
          ),
        ),
        RepositoryProvider<AIServiceManager>(
          create: (context) => AIServiceManager(
            apiConfigRepository: context.read<APIConfigRepository>(),
          ),
          lazy: false,
        ),
        RepositoryProvider<WordPairService>(
          create: (context) => WordPairService(
            usedWordsStorage: context.read<UsedWordsStorage>(),
            aiServiceManager: context.read<AIServiceManager>(),
          ),
        ),
      ],
      child: Builder(builder: (context) {
        return MultiBlocProvider(
          providers: <BlocProvider<StateStreamableSource<Object?>>>[
            BlocProvider<ThemeModeBloc>(
              create: (context) => ThemeModeBloc(),
            ),
            BlocProvider<AnalyticsBloc>(
              create: (context) => AnalyticsBloc(
                analyticsRepository: _analyticsRepository,
              ),
              lazy: false,
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(
                feedbackRepository: context.read<FeedbackRepository>(),
              ),
              lazy: false,
            ),
            BlocProvider<CategoryBloc>(
              create: (context) => CategoryBloc(
                categoryRepository: context.read<CategoryRepository>(),
              ),
              lazy: false,
            ),
            BlocProvider<GameBloc>(
              create: (context) => GameBloc(
                playerRepository: context.read<PlayerRepository>(),
                gameRepository: context.read<GameRepository>(),
                wordPairService: context.read<WordPairService>(),
                categoryBloc: context.read<CategoryBloc>(),
              )..add(const GameInitialized()),
            ),
            BlocProvider<AppBloc>(
              create: (final context) => AppBloc(
                appRepository: context.read<AppRepository>(),
              ),
              lazy: false,
            ),
            BlocProvider<APIConfigBloc>(
              create: (context) => APIConfigBloc(
                apiConfigRepository: context.read<APIConfigRepository>(),
              )..add(const APIConfigInitialized()),
              lazy: false,
            ),
          ],
          child: APIServiceProvider(
            child: const AppView(),
          ),
        );
      }),
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
              home: const LocalizationInitializer(
                child: HomePage(),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget that initializes localization-dependent services
class LocalizationInitializer extends StatefulWidget {
  const LocalizationInitializer({required this.child, super.key});

  final Widget child;

  @override
  State<LocalizationInitializer> createState() =>
      _LocalizationInitializerState();
}

class _LocalizationInitializerState extends State<LocalizationInitializer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // At this point, AppLocalizations is initialized and available
    final l10n = context.l10n;

    // Initialize the formatter in the repository
    final playerRepository = context.read<PlayerRepository>();
    playerRepository
        .initializeFormatter((number) => l10n.playerDefaultName(number));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
