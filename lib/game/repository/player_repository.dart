import "dart:convert";

import "package:uuid/uuid.dart";

import "../../storage/persistent_storage.dart";
import "../models/player.dart";

class PlayerRepository {
  PlayerRepository({
    required PersistentStorage persistentStorage,
  }) : _persistentStorage = persistentStorage;

  final PersistentStorage _persistentStorage;
  String Function(int)? _formatPlayerName;
  static const String _kPlayersKey = "players";
  static const String _kNameCacheKey = "player_name_cache";
  final _uuid = const Uuid();

  /// Initialize the player name formatter
  /// This should be called after the app's localization is ready
  void initializeFormatter(String Function(int) formatter) {
    _formatPlayerName = formatter;
  }

  /// Get the appropriate formatter function with fallback
  String Function(int) _getFormatter() {
    return _formatPlayerName ?? ((number) => "Player $number");
  }

  /// Saves a custom player name to the cache by position
  Future<void> _saveNameToCache(int position, String name) async {
    if (name.trim().isEmpty) return; // Don't cache empty names

    final cachedNamesJson = await _persistentStorage.read(key: _kNameCacheKey);
    Map<String, dynamic> nameCache = {};

    if (cachedNamesJson != null && cachedNamesJson.isNotEmpty) {
      nameCache = jsonDecode(cachedNamesJson) as Map<String, dynamic>;
    }

    // Save name by position (convert position to string for JSON keys)
    nameCache[position.toString()] = name;

    // Write back to storage
    await _persistentStorage.write(
      key: _kNameCacheKey,
      value: jsonEncode(nameCache),
    );
  }

  /// Gets a cached name for a position if available
  Future<String?> _getNameFromCache(int position) async {
    final cachedNamesJson = await _persistentStorage.read(key: _kNameCacheKey);

    if (cachedNamesJson == null || cachedNamesJson.isEmpty) {
      return null;
    }

    try {
      final nameCache = jsonDecode(cachedNamesJson) as Map<String, dynamic>;
      return nameCache[position.toString()] as String?;
    } catch (e) {
      // If there's an error parsing, just return null
      return null;
    }
  }

  /// Clears a name from the cache for a position
  Future<void> _clearNameFromCache(int position) async {
    final cachedNamesJson = await _persistentStorage.read(key: _kNameCacheKey);

    if (cachedNamesJson == null || cachedNamesJson.isEmpty) {
      return;
    }

    try {
      final nameCache = jsonDecode(cachedNamesJson) as Map<String, dynamic>;
      nameCache.remove(position.toString());

      // Write back to storage
      await _persistentStorage.write(
        key: _kNameCacheKey,
        value: jsonEncode(nameCache),
      );
    } catch (e) {
      // If there's an error parsing, just ignore
    }
  }

  /// Returns the default player names if no players have been saved yet
  Future<List<Player>> getPlayers() async {
    final formatter = _getFormatter();
    final playersJsonString = await _persistentStorage.read(key: _kPlayersKey);

    if (playersJsonString == null || playersJsonString.isEmpty) {
      // Return default player names
      return List.generate(
        3,
        (index) => Player(
          id: _uuid.v4(),
          name: formatter(index + 1),
          isDefaultName: true,
        ),
      );
    }

    try {
      final List<dynamic> playersJson =
          jsonDecode(playersJsonString) as List<dynamic>;
      return playersJson.map((item) {
        final data = item as Map<String, dynamic>;
        return Player(
          id: data["id"] as String,
          name: data["name"] as String,
          isDefaultName: data["isDefaultName"] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      // If parsing failed, return default players
      return List.generate(
        3,
        (index) => Player(
          id: _uuid.v4(),
          name: formatter(index + 1),
          isDefaultName: true,
        ),
      );
    }
  }

  /// Saves the list of players to storage
  Future<void> savePlayers(List<Player> players) async {
    final playersJson = players
        .map(
          (player) => {
            "id": player.id,
            "name": player.name,
            "isDefaultName": player.isDefaultName,
          },
        )
        .toList();

    final jsonString = jsonEncode(playersJson);
    await _persistentStorage.write(key: _kPlayersKey, value: jsonString);
  }

  /// Add a new player with a default name
  Future<List<Player>> addPlayer(List<Player> currentPlayers) async {
    final formatter = _getFormatter();
    final playerCount = currentPlayers.length + 1;
    final position = playerCount;

    // Check if there's a cached name for this position
    final cachedName = await _getNameFromCache(position);

    final newPlayer = Player(
      id: _uuid.v4(),
      name: cachedName ?? formatter(position),
      isDefaultName: cachedName == null, // Not default if using cached name
    );

    final updatedPlayers = [...currentPlayers, newPlayer];
    await savePlayers(updatedPlayers);

    // If we used a cached name, clear it (one-time use)
    if (cachedName != null) {
      await _clearNameFromCache(position);
    }

    return updatedPlayers;
  }

  /// Remove a player by ID
  Future<List<Player>> removePlayer(
      List<Player> currentPlayers, String playerId) async {
    // Find the player and its position
    int? playerPosition;
    Player? playerToRemove;

    for (int i = 0; i < currentPlayers.length; i++) {
      if (currentPlayers[i].id == playerId) {
        playerPosition = i + 1; // 1-based position
        playerToRemove = currentPlayers[i];
        break;
      }
    }

    // Save the name to cache if it's a custom name
    if (playerPosition != null &&
        playerToRemove != null &&
        !playerToRemove.isDefaultName) {
      await _saveNameToCache(playerPosition, playerToRemove.name);
    }

    // Remove the player
    final updatedPlayers =
        currentPlayers.where((player) => player.id != playerId).toList();

    // Update default names to reflect new positions
    final renamedPlayers = _updateDefaultPlayerNames(updatedPlayers);

    await savePlayers(renamedPlayers);
    return renamedPlayers;
  }

  /// Update a player's name
  Future<List<Player>> updatePlayerName(
      List<Player> currentPlayers, String playerId, String newName) async {
    final formatter = _getFormatter();

    // Find the player's position
    int? playerPosition;
    for (int i = 0; i < currentPlayers.length; i++) {
      if (currentPlayers[i].id == playerId) {
        playerPosition = i + 1; // 1-based position
        break;
      }
    }

    final updatedPlayers = currentPlayers.map((player) {
      if (player.id == playerId) {
        // If user has set a custom name, mark as non-default
        final isUserProvidedName = newName.trim().isNotEmpty;
        final isDefaultName = !isUserProvidedName;
        final playerIndex = currentPlayers.indexOf(player);

        // If player is explicitly clearing their name, also clear from cache
        if (!isUserProvidedName &&
            !player.isDefaultName &&
            playerPosition != null) {
          // Call asynchronously - we don't need to wait for this
          _clearNameFromCache(playerPosition);
        }

        return player.copyWith(
          name: isUserProvidedName ? newName : formatter(playerIndex + 1),
          isDefaultName: isDefaultName,
        );
      }
      return player;
    }).toList();
    await savePlayers(updatedPlayers);
    return updatedPlayers;
  }

  /// Update default player names based on their position in the list
  List<Player> _updateDefaultPlayerNames(List<Player> players) {
    final formatter = _getFormatter();
    return players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;

      // Only update players with default names
      if (player.isDefaultName) {
        // Update to new position-based name
        return player.copyWith(name: formatter(index + 1));
      }
      return player;
    }).toList();
  }

  /// Update default player names to the given locale's format
  Future<List<Player>> updateDefaultPlayerNamesFormat(
      List<Player> players) async {
    final formatter = _getFormatter();
    final updatedPlayers = players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;

      if (player.isDefaultName) {
        // Update to translated default name format
        return player.copyWith(name: formatter(index + 1));
      }
      return player;
    }).toList();

    await savePlayers(updatedPlayers);
    return updatedPlayers;
  }
}
