import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/game.dart';
import '../models/player.dart';
import '../models/word_pair_results.dart';
import '../repository/category_repository.dart';
import '../repository/game_repository.dart';
import '../repository/player_repository.dart';
import '../services/word_pair_service.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required PlayerRepository playerRepository,
    required CategoryRepository categoryRepository,
    required GameRepository gameRepository,
    required WordPairService wordPairService,
  })  : _playerRepository = playerRepository,
        _categoryRepository = categoryRepository,
        _gameRepository = gameRepository,
        _wordPairService = wordPairService,
        super(const GameState()) {
    on<GameInitialized>(_onGameInitialized);

    // Player Setup Page events
    on<PlayerAdded>(_onPlayerAdded);
    on<PlayerRemoved>(_onPlayerRemoved);
    on<PlayerNameUpdated>(_onPlayerNameUpdated);

    // Game Settings Page events
    on<WolvesCountUpdated>(_onWolvesCountUpdated);
    on<GameDiscussionTimeUpdated>(_onGameDiscussionTimeUpdated);
    on<WordPairSimilarityUpdated>(_onWordPairSimilarityUpdated);

    // Game Categories Page preload events
    on<PresetCategoriesLoaded>(_onPresetCategoriesLoaded);
    on<SavedCategoriesLoaded>(_onSavedCategoriesLoaded);

    // Game Categories Page events
    on<GameCategorySearchUpdated>(_onGameCategorySearchUpdated);
    on<GameCategoryUpdated>(_onGameCategoryUpdated);
    on<CategorySaved>(_onCategorySaved);
    on<CategoryRemoved>(_onCategoryRemoved);

    // Distribute Words Page events
    on<GameStarted>(_onGameStarted);

    // Unused events
    on<GamePhaseAdvanced>(_onGamePhaseAdvanced);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<GameReset>(_onGameReset);
  }

  final PlayerRepository _playerRepository;
  final CategoryRepository _categoryRepository;
  final GameRepository _gameRepository;
  final WordPairService _wordPairService;
  Timer? _timer;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onGameInitialized(
    GameInitialized event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStatus.loading));
    try {
      // Get players from repository
      final players = await _playerRepository.getPlayers();

      // Get saved categories from repository
      final savedCategories = await _categoryRepository.getSavedCategories();

      // Create initial game
      var game = Game(
        players: players,
        savedCategories: savedCategories,
      );

      // Load and apply saved settings
      game = await _gameRepository.loadSettings(game);

      emit(
        state.copyWith(
          status: GameStatus.ready,
          game: game,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to load game data: $error',
        ),
      );
    }
  }

  // Save current game settings to repository
  Future<void> _saveSettings() async {
    await _gameRepository.saveGameSettings(
      category: state.game.category,
      customWolfCount: state.game.customWolfCount,
      randomizeWolfCount: state.game.randomizeWolfCount,
      autoAssignWolves: state.game.autoAssignWolves,
      discussionTimeInSeconds: state.game.discussionTimeInSeconds,
      wordPairSimilarity: state.game.wordPairSimilarity,
    );
  }

  // Player Setup Page events
  Future<void> _onPlayerAdded(
    PlayerAdded event,
    Emitter<GameState> emit,
  ) async {
    try {
      final updatedPlayers =
          await _playerRepository.addPlayer(state.game.players);
      emit(
        state.copyWith(
          game: state.game.copyWith(players: updatedPlayers),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to add player: $error',
        ),
      );
    }
  }

  Future<void> _onPlayerRemoved(
    PlayerRemoved event,
    Emitter<GameState> emit,
  ) async {
    try {
      if (state.game.players.length <= 3) {
        emit(
          state.copyWith(
            status: GameStatus.error,
            error: 'Cannot remove player. Minimum 3 players required.',
          ),
        );
        return;
      }

      // Removal now caches custom names by position
      final updatedPlayers = await _playerRepository.removePlayer(
        state.game.players,
        event.playerId,
      );

      // Calculate max allowed wolves for new player count
      final maxWolves = ((updatedPlayers.length - 1) / 2).floor();
      final currentWolves = state.game.customWolfCount ??
          (state.game.autoAssignWolves
              ? (updatedPlayers.length / 5).ceil()
              : state.game.customWolfCount ?? 1);

      // Adjust wolf count if it exceeds the maximum allowed
      final adjustedWolves =
          currentWolves > maxWolves ? maxWolves : currentWolves;

      emit(
        state.copyWith(
          game: state.game.copyWith(
            players: updatedPlayers,
            // Update wolf count if it needed adjustment
            customWolfCount: adjustedWolves != currentWolves
                ? adjustedWolves
                : state.game.customWolfCount,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to remove player: $error',
        ),
      );
    }
  }

  Future<void> _onPlayerNameUpdated(
    PlayerNameUpdated event,
    Emitter<GameState> emit,
  ) async {
    try {
      final updatedPlayers = await _playerRepository.updatePlayerName(
        state.game.players,
        event.playerId,
        event.name,
      );
      emit(
        state.copyWith(
          game: state.game.copyWith(players: updatedPlayers),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to update player name: $error',
        ),
      );
    }
  }

  // Game Settings Page events
  void _onWolvesCountUpdated(
    WolvesCountUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          customWolfCount: event.numberOfWolves,
          randomizeWolfCount: event.randomizeWolfCount,
          autoAssignWolves: event.autoAssignWolves,
        ),
      ),
    );

    // Save settings to repository
    _saveSettings();
  }

  void _onGameDiscussionTimeUpdated(
    GameDiscussionTimeUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          discussionTimeInSeconds: event.timeInSeconds,
        ),
      ),
    );

    // Save settings to repository
    _saveSettings();
  }

  void _onWordPairSimilarityUpdated(
    WordPairSimilarityUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          wordPairSimilarity: event.similarity,
        ),
      ),
    );

    // Save settings to repository
    _saveSettings();
  }

  // Game Categories Page preload events
  Future<void> _onPresetCategoriesLoaded(
    PresetCategoriesLoaded event,
    Emitter<GameState> emit,
  ) async {
    try {
      final presetCategories = await _categoryRepository.getPresetCategories();
      emit(
        state.copyWith(
          game: state.game.copyWith(presetCategories: presetCategories),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to load preset categories: $error',
        ),
      );
    }
  }

  Future<void> _onSavedCategoriesLoaded(
    SavedCategoriesLoaded event,
    Emitter<GameState> emit,
  ) async {
    try {
      final savedCategories = await _categoryRepository.getSavedCategories();
      emit(
        state.copyWith(
          game: state.game.copyWith(savedCategories: savedCategories),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to load saved categories: $error',
        ),
      );
    }
  }

  // Game Categories Page events
  void _onGameCategorySearchUpdated(
    GameCategorySearchUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(categorySearchText: event.searchText),
      ),
    );
  }

  void _onGameCategoryUpdated(
    GameCategoryUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(category: event.category),
      ),
    );

    // When a category is selected, update its lastUsedAt timestamp
    if (event.category.isNotEmpty) {
      add(CategorySaved(event.category));
    }

    // Save settings to repository
    _saveSettings();
  }

  Future<void> _onCategorySaved(
    CategorySaved event,
    Emitter<GameState> emit,
  ) async {
    try {
      final savedCategories = await _categoryRepository.addOrUpdateCategory(
        event.category,
      );
      emit(
        state.copyWith(
          game: state.game.copyWith(savedCategories: savedCategories),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to save category: $error',
        ),
      );
    }
  }

  Future<void> _onCategoryRemoved(
    CategoryRemoved event,
    Emitter<GameState> emit,
  ) async {
    try {
      final savedCategories = await _categoryRepository.removeCategory(
        event.category,
      );

      // Check if the removed category is the currently selected category
      final updatedGame = state.game.copyWith(
        savedCategories: savedCategories,
        // If the removed category is the selected one, clear it
        category:
            state.game.category == event.category ? '' : state.game.category,
      );

      emit(
        state.copyWith(
          game: updatedGame,
        ),
      );

      // Save settings if category changed
      if (state.game.category != updatedGame.category) {
        _saveSettings();
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to remove category: $error',
        ),
      );
    }
  }

  // Distribute Words Page events
  Future<void> _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStatus.loading));

    final random = Random();
    final wolfCount = state.game.wolfCount;
    final playerCount = state.game.players.length;

    // Select random player indices to be wolves
    final wolfIndices = <int>{};
    while (wolfIndices.length < wolfCount) {
      wolfIndices.add(random.nextInt(playerCount));
    }

    // Assign roles to players
    final playersWithRoles = state.game.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final role =
          wolfIndices.contains(index) ? PlayerRole.wolf : PlayerRole.citizen;
      return player.copyWith(role: role);
    }).toList();

    //TODO: Remove this after testing
    await Future.delayed(const Duration(seconds: 1));

    WordPairResult result;
    try {
      // Get a random word pair based on selected category and similarity
      result = await _wordPairService.getRandomWordPair(
        category: state.game.category,
        similarity: state.game.wordPairSimilarity,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Failed to get word pair: $error',
        ),
      );
      return;
    }

    // Start the game with word assignment phase
    emit(
      state.copyWith(
        status: GameStatus.inProgress,
        game: state.game.copyWith(
          players: playersWithRoles,
          citizenWord: result.words[0],
          wolfWord: result.words[1],
          // Override category if it was previously filled
          category: state.game.category.isNotEmpty ? result.category : '',
          phase: GamePhase.wordAssignment,
        ),
      ),
    );
  }

  // Unused events
  void _onGamePhaseAdvanced(
    GamePhaseAdvanced event,
    Emitter<GameState> emit,
  ) {
    final currentPhase = state.game.phase;

    switch (currentPhase) {
      case GamePhase.setup:
        emit(
          state.copyWith(
            game: state.game.copyWith(phase: GamePhase.wordAssignment),
          ),
        );
        break;
      case GamePhase.wordAssignment:
        emit(
          state.copyWith(
            game: state.game.copyWith(
              phase: GamePhase.discussion,
              remainingTimeInSeconds: state.game.discussionTimeInSeconds,
            ),
          ),
        );
        _startTimer();
        break;
      case GamePhase.discussion:
        _timer?.cancel();
        emit(
          state.copyWith(
            game: state.game.copyWith(
              phase: GamePhase.voting,
              remainingTimeInSeconds: 0,
            ),
          ),
        );
        break;
      case GamePhase.voting:
        emit(
          state.copyWith(
            game: state.game.copyWith(phase: GamePhase.results),
          ),
        );
        break;
      case GamePhase.results:
        break;
    }
  }

  void _onGameTimerTicked(
    GameTimerTicked event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          remainingTimeInSeconds: event.remainingSeconds,
        ),
      ),
    );

    if (event.remainingSeconds <= 0) {
      _timer?.cancel();
      add(const GamePhaseAdvanced());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final remainingSeconds = state.game.remainingTimeInSeconds - 1;
        add(GameTimerTicked(remainingSeconds));
      },
    );
  }

  void _onGameReset(
    GameReset event,
    Emitter<GameState> emit,
  ) {
    _timer?.cancel();

    // Reset the game but keep players and settings
    emit(
      state.copyWith(
        status: GameStatus.ready,
        game: state.game.copyWith(
          phase: GamePhase.setup,
          remainingTimeInSeconds: 0,
          // Reset player roles
          players: state.game.players
              .map(
                (player) => player.copyWith(role: PlayerRole.undecided),
              )
              .toList(),
        ),
      ),
    );
  }
}
