import "dart:async";
import "dart:math";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

import "../../category/bloc/category_bloc.dart";
import "../models/game.dart";
import "../models/player.dart";
import "../models/word_pair_results.dart";
import "../repository/game_repository.dart";
import "../repository/player_repository.dart";
import "../services/word_pair_service.dart";

part "game_event.dart";
part "game_state.dart";

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
    on<AutoAssignUpdated>(_onAutoAssignUpdated);
    on<RandomizeWolfCountUpdated>(_onRandomizeWolfCountUpdated);
    on<WolvesCountUpdated>(_onWolvesCountUpdated);
    on<GameDiscussionTimeUpdated>(_onGameDiscussionTimeUpdated);
    on<WordPairSimilarityUpdated>(_onWordPairSimilarityUpdated);
    on<WolfRevengeUpdated>(_onWolfRevengeUpdated);

    // Distribute Words Page events
    on<GameStarted>(_onGameStartedOnline);
    on<GameStartedOffline>(_onGameStartedOffline);

    // Discussion Page events
    on<DiscussionStarted>(_onDiscussionStarted);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<GameTimerPaused>(_onGameTimerPaused);
    on<GameTimerAdjusted>(_onGameTimerAdjusted);
    on<IcebreakerLabelRevealed>(_onIcebreakerLabelRevealed);

    // Voting Page events
    on<VotingStarted>(_onVotingStarted);
    on<SuddenDeathStarted>(_onSuddenDeathStarted);
    on<PlayerVoted>(_onPlayerVoted);

    // Wolf's Revenge events
    on<WolfRevengeGuess>(_onWolfRevengeGuess);
    on<WolfRevengeVerbalGuess>(_onWolfRevengeVerbalGuess);
    on<WolfRevengeSkipped>(_onWolfRevengeSkipped);
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
          error: "Failed to load game data: $error",
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
          error: "Failed to add player: $error",
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
            error: "Cannot remove player. Minimum 3 players required.",
          ),
        );
        return;
      }

      // Removal now caches custom names by position
      final updatedPlayers = await _playerRepository.removePlayer(
        state.game.players,
        event.playerId,
      );

      final updatedPlayerCount = updatedPlayers.length;
      final updatedMaxWolves = Game.getMaxWolfCount(updatedPlayerCount);

      int? adjustedCustomWolfCount;
      final currentCustomWolfCount = state.game.customWolfCount;
      if (currentCustomWolfCount != null) {
        if (currentCustomWolfCount < 1) {
          adjustedCustomWolfCount = 1;
        } else if (currentCustomWolfCount > updatedMaxWolves) {
          adjustedCustomWolfCount = updatedMaxWolves;
        } else {
          adjustedCustomWolfCount = currentCustomWolfCount;
        }
      }

      bool adjustedRandomizeWolfCount = state.game.randomizeWolfCount;
      if (adjustedRandomizeWolfCount && updatedMaxWolves < 2) {
        adjustedRandomizeWolfCount = false;
      }

      emit(
        state.copyWith(
          game: state.game.copyWith(
            players: updatedPlayers,
            customWolfCount: adjustedCustomWolfCount,
            randomizeWolfCount: adjustedRandomizeWolfCount,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: "Failed to remove player: $error",
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
          error: "Failed to update player name: $error",
        ),
      );
    }
  }

  // Game Settings Page events
  void _onAutoAssignUpdated(
    AutoAssignUpdated event,
    Emitter<GameState> emit,
  ) {
    final defaultWolfCount = Game.getDefaultWolfCount(
      state.game.players.length,
    );

    emit(
      state.copyWith(
        game: state.game.copyWith(
          autoAssignWolves: event.enabled,
          randomizeWolfCount: !event.enabled && state.game.randomizeWolfCount,
          customWolfCount: defaultWolfCount,
        ),
      ),
    );

    // Save settings to repository
    _saveSettings();
  }

  void _onRandomizeWolfCountUpdated(
    RandomizeWolfCountUpdated event,
    Emitter<GameState> emit,
  ) {
    final customWolfCount = state.game.customWolfCount;

    emit(
      state.copyWith(
        game: state.game.copyWith(
          randomizeWolfCount: event.enabled,
          autoAssignWolves: !event.enabled && state.game.autoAssignWolves,
          customWolfCount: event.enabled ? null : customWolfCount,
        ),
      ),
    );

    // Save settings to repository
    _saveSettings();
  }

  void _onWolvesCountUpdated(
    WolvesCountUpdated event,
    Emitter<GameState> emit,
  ) {
    final currentWolfCount = state.game.customWolfCount ?? 1;
    final newWolfCount = currentWolfCount + event.count;
    final maxWolves = Game.getMaxWolfCount(state.game.players.length);

    if (newWolfCount > maxWolves || newWolfCount < 1) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: "Cannot have more wolves than players or less than 1 wolf.",
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        game: state.game.copyWith(
          customWolfCount: newWolfCount,
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
    final currentTimeInSeconds = state.game.discussionTimeInSeconds;
    final newTimeInSeconds = currentTimeInSeconds + event.timeInSeconds;

    if (newTimeInSeconds > 30 * 60 || newTimeInSeconds <= 0) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: "Discussion time must be between 0 and 30 minutes.",
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        game: state.game.copyWith(
          discussionTimeInSeconds: newTimeInSeconds,
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
    String category,
    bool online,
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
      if (online) {
        // Get a random word pair based on selected category and similarity
        result = await _wordPairService.getRandomWordPair(
          category: category,
          similarity: state.game.wordPairSimilarity,
        );
      } else {
        result = await _wordPairService.getRandomOfflineWordPair();
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: "Failed to get word pair: $error",
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

  Future<void> _onGameStartedOnline(
    GameStarted event,
    Emitter<GameState> emit,
  ) async {
    await _onGameStarted(event.category, true, emit);
  }

  Future<void> _onGameStartedOffline(
    GameStartedOffline event,
    Emitter<GameState> emit,
  ) async {
    await _onGameStarted(event.category, false, emit);
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

  void _onIcebreakerLabelRevealed(
    IcebreakerLabelRevealed event,
    Emitter<GameState> emit,
  ) {
    // Create a new set with the existing revealed indices
    final updatedRevealedIndices =
        Set<int>.from(state.game.revealedIcebreakerIndices);
    // Add the newly revealed index
    updatedRevealedIndices.add(event.index);

    // Update the game state with the new set
    emit(
      state.copyWith(
        game: state.game.copyWith(
          revealedIcebreakerIndices: updatedRevealedIndices,
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
    // Immediately emit the updated state
    emit(
      state.copyWith(
        game: state.game.copyWith(
          selectedPlayerId: event.selectedPlayerId,
          // Reset any previous wolf revenge attempts
          wolfRevengeAttempted: false,
          wolfRevengeSuccessful: false,
        ),
      ),
    );
  }

  // Wolf's Revenge events
  void _onWolfRevengeGuess(
    WolfRevengeGuess event,
    Emitter<GameState> emit,
  ) {
    final guess = event.guess.toLowerCase().trim();
    final citizenWord = state.game.citizenWord.toLowerCase().trim();

    // Exact match
    if (guess == citizenWord) {
      emit(
        state.copyWith(
          game: state.game.copyWith(
            wolfRevengeAttempted: true,
            wolfRevengeSuccessful: true,
          ),
        ),
      );
      return;
    }

    // Fuzzy matching for similar words
    if (_isSimilarEnough(guess, citizenWord)) {
      emit(
        state.copyWith(
          game: state.game.copyWith(
            wolfRevengeAttempted: true,
            wolfRevengeSuccessful: true,
          ),
        ),
      );
      return;
    }

    // Not a match
    emit(
      state.copyWith(
        game: state.game.copyWith(
          wolfRevengeAttempted: true,
          wolfRevengeSuccessful: false,
        ),
      ),
    );
  }

  // Simple fuzzy matching using Levenshtein distance algorithm
  bool _isSimilarEnough(String input, String target) {
    // Empty strings are never similar
    if (input.isEmpty || target.isEmpty) return false;

    // For very short words (3 chars or less), only allow 1 character difference
    if (target.length <= 3) {
      return _levenshteinDistance(input, target) <= 1;
    }

    // For words 4-6 chars, allow 2 character differences
    if (target.length <= 6) {
      return _levenshteinDistance(input, target) <= 2;
    }

    // For longer words, allow differences of up to 30% of the word length
    final maxDistance = (target.length * 0.3).floor();
    return _levenshteinDistance(input, target) <= maxDistance;
  }

  // Levenshtein distance calculation
  int _levenshteinDistance(String a, String b) {
    // Create a table to store results of sub-problems
    final rows = a.length + 1;
    final cols = b.length + 1;
    final d = List.generate(rows, (_) => List<int>.filled(cols, 0));

    // Source prefixes can be transformed into empty string by
    // dropping all characters
    for (var i = 0; i < rows; i++) {
      d[i][0] = i;
    }

    // Target prefixes can be reached from empty source prefix
    // by inserting every character
    for (var j = 0; j < cols; j++) {
      d[0][j] = j;
    }

    for (var j = 1; j < cols; j++) {
      for (var i = 1; i < rows; i++) {
        final substitutionCost = a[i - 1] == b[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // deletion
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + substitutionCost, // substitution
        ].reduce((curr, next) => curr < next ? curr : next);
      }
    }

    return d[a.length][b.length];
  }

  void _onWolfRevengeVerbalGuess(
    WolfRevengeVerbalGuess event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          wolfRevengeAttempted: true,
          wolfRevengeSuccessful: event.correct,
        ),
      ),
    );
  }

  void _onWolfRevengeSkipped(
    WolfRevengeSkipped event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          wolfRevengeAttempted: true,
          wolfRevengeSuccessful: false,
        ),
      ),
    );
  }
}
