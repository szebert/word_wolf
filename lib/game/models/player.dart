import 'package:equatable/equatable.dart';

enum PlayerRole {
  citizen,
  wolf,
  undecided,
}

class Player extends Equatable {
  const Player({
    required this.id,
    required this.name,
    this.role = PlayerRole.undecided,
    this.isDefaultName = true,
  });

  final String id;
  final String name;
  final PlayerRole role;
  final bool isDefaultName;

  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    bool? isDefaultName,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isDefaultName: isDefaultName ?? this.isDefaultName,
    );
  }

  @override
  List<Object?> get props => [id, name, role, isDefaultName];

  /// Creates an empty player with a blank ID
  factory Player.empty() {
    return Player(
      id: '',
      name: '',
      isDefaultName: true,
      role: PlayerRole.undecided,
    );
  }
}
