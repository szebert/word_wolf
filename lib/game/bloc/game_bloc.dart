import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/game.dart';
import '../models/player.dart';
import '../repository/player_repository.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required PlayerRepository playerRepository,
  })  : _playerRepository = playerRepository,
        super(const GameState()) {
    on<GameInitialized>(_onGameInitialized);
    on<PlayerAdded>(_onPlayerAdded);
    on<PlayerRemoved>(_onPlayerRemoved);
    on<PlayerNameUpdated>(_onPlayerNameUpdated);
    on<GameCategoryUpdated>(_onGameCategoryUpdated);
    on<GameWordsUpdated>(_onGameWordsUpdated);
    on<GameDiscussionTimeUpdated>(_onGameDiscussionTimeUpdated);
    on<GameStarted>(_onGameStarted);
    on<GamePhaseAdvanced>(_onGamePhaseAdvanced);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<GameReset>(_onGameReset);
  }

  final PlayerRepository _playerRepository;
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
      List<Player> players = await _playerRepository.getPlayers();

      final game = Game(players: players);
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
          error: 'Failed to load players: $error',
        ),
      );
    }
  }

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

      emit(
        state.copyWith(
          game: state.game.copyWith(players: updatedPlayers),
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

  void _onGameCategoryUpdated(
    GameCategoryUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(category: event.category),
      ),
    );
  }

  void _onGameWordsUpdated(
    GameWordsUpdated event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        game: state.game.copyWith(
          citizenWord: event.citizenWord,
          wolfWord: event.wolfWord,
        ),
      ),
    );
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
  }

  void _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) {
    if (!state.canStartGame) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          error: 'Cannot start game. Check player count and game settings.',
        ),
      );
      return;
    }

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

    // Start the game with word assignment phase
    emit(
      state.copyWith(
        status: GameStatus.inProgress,
        game: state.game.copyWith(
          players: playersWithRoles,
          phase: GamePhase.wordAssignment,
        ),
      ),
    );
  }

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
