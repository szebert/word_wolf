import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../category/bloc/category_bloc.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/word_pair_results.dart';
import '../repository/game_repository.dart';
import '../repository/player_repository.dart';
import '../services/word_pair_service.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required PlayerRepository playerRepository,
    required GameRepository gameRepository,
    required WordPairService wordPairService,
    required CategoryBloc categoryBloc,
  })  : _playerRepository = playerRepository,
        _gameRepository = gameRepository,
        _wordPairService = wordPairService,
        _categoryBloc = categoryBloc,
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
    on<WolfRevengeUpdated>(_onWolfRevengeUpdated);

    // Distribute Words Page events
    on<GameStarted>(_onGameStarted);

    // Discussion Page events
    on<DiscussionStarted>(_onDiscussionStarted);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<GameTimerPaused>(_onGameTimerPaused);
    on<GameTimerAdjusted>(_onGameTimerAdjusted);

    // Voting Page events
    on<VotingStarted>(_onVotingStarted);
    on<SuddenDeathStarted>(_onSuddenDeathStarted);
    on<PlayerVoted>(_onPlayerVoted);
  }

  final PlayerRepository _playerRepository;
  final GameRepository _gameRepository;
  final WordPairService _wordPairService;
  final CategoryBloc _categoryBloc;
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

      // Create initial game
      var game = Game(
        players: players,
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
      customWolfCount: state.game.customWolfCount,
      randomizeWolfCount: state.game.randomizeWolfCount,
      autoAssignWolves: state.game.autoAssignWolves,
      discussionTimeInSeconds: state.game.discussionTimeInSeconds,
      wordPairSimilarity: state.game.wordPairSimilarity,
      wolfRevengeEnabled: state.game.wolfRevengeEnabled,
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
          customWolfCount: event.customWolfCount,
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

  void _onWolfRevengeUpdated(
    WolfRevengeUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          wolfRevengeEnabled: event.enabled,
        ),
      ),
    );

    // Save settings to repository
    _saveSettings();
  }

  // Distribute Words Page events
  Future<void> _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(status: GameStatus.loading));

    final random = Random();
    final wolfCount = state.game.generateWolfCount;
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

    WordPairResult result;
    try {
      // Get a random word pair based on selected category and similarity
      result = await _wordPairService.getRandomWordPair(
        category: event.category,
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

    // If there's already a selected category and it's different from the word
    // pair service, override it
    if (result.category.isNotEmpty &&
        result.category != _categoryBloc.state.selectedCategory &&
        _categoryBloc.state.selectedCategory.isNotEmpty) {
      _categoryBloc.add(CategorySelected(categoryName: result.category));
    }

    // Start the game with word assignment phase
    emit(
      state.copyWith(
        status: GameStatus.inProgress,
        game: state.game.copyWith(
          players: playersWithRoles,
          citizenWord: result.words[0],
          wolfWord: result.words[1],
          icebreakers: result.icebreakers,
          phase: GamePhase.wordAssignment,
        ),
      ),
    );
  }

  // Discussion Page events
  void _onDiscussionStarted(
    DiscussionStarted event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          phase: GamePhase.discussion,
          remainingTimeInSeconds: state.game.discussionTimeInSeconds,
        ),
      ),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final remainingSeconds = state.game.remainingTimeInSeconds - 1;
        add(GameTimerTicked(remainingSeconds: remainingSeconds));
      },
    );
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
      add(const VotingStarted());
    }
  }

  void _onGameTimerPaused(
    GameTimerPaused event,
    Emitter<GameState> emit,
  ) {
    if (event.paused) {
      // Pause the timer
      _timer?.cancel();
    } else {
      // Resume the timer
      _startTimer();
    }
  }

  void _onGameTimerAdjusted(
    GameTimerAdjusted event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          remainingTimeInSeconds: event.newTimeInSeconds,
        ),
      ),
    );
  }

  // Voting Page events
  void _onVotingStarted(
    VotingStarted event,
    Emitter<GameState> emit,
  ) {
    // Cancel any existing timer
    _timer?.cancel();

    emit(
      state.copyWith(
        game: state.game.copyWith(phase: GamePhase.voting),
      ),
    );
  }

  void _onSuddenDeathStarted(
    SuddenDeathStarted event,
    Emitter<GameState> emit,
  ) {
    // Cancel any existing timer
    _timer?.cancel();

    // Set the timer to 1 minute for sudden death
    emit(
      state.copyWith(
        game: state.game.copyWith(
          phase: GamePhase.discussion,
          remainingTimeInSeconds: 60, // 1 minute
        ),
      ),
    );

    // Start the timer
    _startTimer();
  }

  void _onPlayerVoted(
    PlayerVoted event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          selectedPlayerId: event.selectedPlayerId,
        ),
      ),
    );
  }
}
