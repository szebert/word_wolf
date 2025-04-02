import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_ui/app_spacing.dart';
import '../../app_ui/widgets/app_button.dart';
import '../../app_ui/widgets/app_icon_button.dart';
import '../../app_ui/widgets/app_text.dart';
import '../../l10n/l10n.dart';
import '../bloc/game_bloc.dart';
import '../models/player.dart';
import 'game_settings_page.dart';

class PlayerSetupPage extends StatefulWidget {
  const PlayerSetupPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const PlayerSetupPage(),
    );
  }

  @override
  State<PlayerSetupPage> createState() => _PlayerSetupPageState();
}

class _PlayerSetupPageState extends State<PlayerSetupPage> {
  // Track currently editing player ID
  String? _editingPlayerId;

  // Reference to save function for current editor
  VoidCallback? _saveCurrentEdit;

  // Save current edit and set new editing player
  void _setEditingPlayer(String? playerId, [VoidCallback? saveCallback]) {
    // If there's a current edit active, save it first
    if (_editingPlayerId != null && _saveCurrentEdit != null) {
      _saveCurrentEdit!();
    }

    setState(() {
      _editingPlayerId = playerId;
      _saveCurrentEdit = saveCallback;
    });
  }

  void _continueToNextStep() {
    // Save any active edit before navigating
    _setEditingPlayer(null);
    Navigator.of(context).push(GameSettingsPage.route());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          l10n.playerSetup,
          variant: AppTextVariant.titleLarge,
        ),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.back,
        ),
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Player count indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIconButton(
                      icon: const Icon(Icons.remove_circle),
                      tooltip: l10n.playerRemoved,
                      iconSize: 32,
                      onPressed: state.game.players.length > 3
                          ? () {
                              // Save any current edit before removing player
                              _setEditingPlayer(null);

                              // Remove the last player
                              final lastPlayer = state.game.players.last;
                              context.read<GameBloc>().add(
                                    PlayerRemoved(
                                      playerId: lastPlayer.id,
                                    ),
                                  );
                            }
                          : null,
                    ),
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          AppText(
                            '${state.game.players.length}',
                            variant: AppTextVariant.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          AppText(
                            l10n.players,
                            variant: AppTextVariant.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: const Icon(Icons.add_circle),
                      tooltip: l10n.playerAdded,
                      iconSize: 32,
                      onPressed: state.game.players.length < 30
                          ? () {
                              // Save any current edit before adding player
                              _setEditingPlayer(null);

                              context.read<GameBloc>().add(
                                    const PlayerAdded(),
                                  );
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // List of players
                Expanded(
                  child: ListView.builder(
                    itemCount: state.game.players.length,
                    itemBuilder: (context, index) {
                      final player = state.game.players[index];
                      return PlayerListItem(
                        player: player,
                        index: index + 1,
                        isEditing: player.id == _editingPlayerId,
                        onEditingChanged: (isEditing, saveCallback) {
                          if (isEditing) {
                            // Starting edit - save any current edit first
                            _setEditingPlayer(player.id, saveCallback);
                          } else if (player.id == _editingPlayerId) {
                            // Ending edit for this player
                            _setEditingPlayer(null);
                          }
                        },
                      );
                    },
                  ),
                ),

                // Next button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: AppButton(
                      variant: AppButtonVariant.elevated,
                      onPressed: _continueToNextStep,
                      child: AppText(
                        l10n.next,
                        variant: AppTextVariant.titleMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PlayerListItem extends StatefulWidget {
  const PlayerListItem({
    required this.player,
    required this.index,
    required this.isEditing,
    required this.onEditingChanged,
    super.key,
  });

  final Player player;
  final int index;
  final bool isEditing;
  final Function(bool, VoidCallback) onEditingChanged;

  @override
  State<PlayerListItem> createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<PlayerListItem> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  bool get _isDefaultName => widget.player.isDefaultName;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.player.name);
    _hasText = _controller.text.isNotEmpty;

    // Listen for text changes to update the clear button visibility
    _controller.addListener(_updateTextState);
  }

  void _updateTextState() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void didUpdateWidget(covariant PlayerListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller text if player name changed
    if (oldWidget.player.name != widget.player.name) {
      _controller.text = widget.player.name;
      _hasText = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateTextState);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _savePlayerName() {
    if (widget.isEditing) {
      final currentValue = _controller.text.trim();

      // Send the name update to the bloc
      context.read<GameBloc>().add(
            PlayerNameUpdated(
              playerId: widget.player.id,
              // If empty, let the repository handle defaulting
              name: currentValue,
            ),
          );
    }
  }

  void _startEditing() {
    // Clear the text if it's the default name
    if (_isDefaultName) {
      _controller.text = '';
    }
    widget.onEditingChanged(true, _savePlayerName);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Player number badge
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: AppText(
                widget.index.toString(),
                variant: AppTextVariant.titleMedium,
                weight: AppTextWeight.bold,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Player name text field
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isEditing
                      ? Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withAlpha(127)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isEditing
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: widget.isEditing
                    ? _buildEditableField()
                    : _buildDisplayField(),
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                AppIconButton(
                  icon: Icon(widget.isEditing ? Icons.done : Icons.edit),
                  tooltip: widget.isEditing ? l10n.playerSave : l10n.playerEdit,
                  onPressed: () {
                    if (widget.isEditing) {
                      _savePlayerName();
                      widget.onEditingChanged(false, _savePlayerName);
                    } else {
                      _startEditing();
                    }
                  },
                ),

                // Delete button
                AppIconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.playerDelete,
                  color: Theme.of(context).colorScheme.error,
                  onPressed:
                      context.read<GameBloc>().state.game.players.length > 3
                          ? () {
                              // Save any edits before deleting
                              if (widget.isEditing) {
                                _savePlayerName();
                                widget.onEditingChanged(false, _savePlayerName);
                              }

                              context.read<GameBloc>().add(
                                    PlayerRemoved(
                                      playerId: widget.player.id,
                                    ),
                                  );
                            }
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField() {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text field
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: true,
            maxLength: 30, // Increased max length
            buildCounter: (context,
                    {required currentLength,
                    required maxLength,
                    required isFocused}) =>
                null, // Hide counter
            decoration: InputDecoration(
              hintText: l10n.playerDefaultName(widget.index),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _savePlayerName(),
          ),
        ),

        // Clear button (X)
        if (_hasText)
          SizedBox(
            height: 24,
            width: 24,
            child: AppIconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.clear, size: 18),
              tooltip: l10n.playerClear,
              onPressed: () {
                _controller.clear();
                setState(() {
                  _hasText = false;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDisplayField() {
    final l10n = context.l10n;
    // If using default name, use the localized format
    final displayText = widget.player.isDefaultName
        ? l10n.playerDefaultName(widget.index)
        : widget.player.name;

    return AppText(
      displayText,
      variant: AppTextVariant.bodyLarge,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
