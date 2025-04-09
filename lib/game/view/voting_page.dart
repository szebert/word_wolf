import "package:audioplayers/audioplayers.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:vibration/vibration.dart";

import "../../app_ui/app_config.dart";
import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_button.dart";
import "../../app_ui/widgets/app_exit_scope.dart";
import "../../app_ui/widgets/app_list_tile.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../models/game.dart";
import "../models/player.dart";
import "discussion_page.dart";
import "results_page.dart";
import "wolf_revenge_page.dart";

class VotingPage extends StatelessWidget {
  const VotingPage({
    super.key,
    this.shouldPlayAlarm = true,
  });

  final bool shouldPlayAlarm;

  static Route<void> route({bool shouldPlayAlarm = true}) {
    return MaterialPageRoute<void>(
      builder: (_) => VotingPage(shouldPlayAlarm: shouldPlayAlarm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VotingView(shouldPlayAlarm: shouldPlayAlarm);
  }
}

class VotingView extends StatefulWidget {
  const VotingView({
    super.key,
    this.shouldPlayAlarm = true,
  });

  final bool shouldPlayAlarm;

  @override
  State<VotingView> createState() => _VotingViewState();
}

class _VotingViewState extends State<VotingView> {
  String? _selectedPlayerId;

  // Static shared audio player
  static AudioPlayer? _sharedAlarmPlayer;
  static int _instanceCount = 0;
  static bool _hasVibrator = false;

  // Local reference to shared player
  AudioPlayer? get _alarmPlayer => _sharedAlarmPlayer;

  // Initialize audio players
  Future<void> _initAudio() async {
    // Check if vibration is supported
    _hasVibrator = await Vibration.hasVibrator();

    try {
      // Increment instance counter
      _instanceCount++;

      // Create the shared player only once
      if (_sharedAlarmPlayer == null) {
        // Create the audio player
        _sharedAlarmPlayer = AudioPlayer();
        // Set the release mode to stop after playback has completed
        await _sharedAlarmPlayer?.setReleaseMode(ReleaseMode.stop);
        // Set the source to the asset
        await _sharedAlarmPlayer?.setSource(AssetSource("audio/alarm.mp3"));
      }
    } catch (e) {
      // Do nothing
    }
  }

  // Dispose audio players
  void _disposeAudio() {
    // Stop alarm sound
    try {
      _sharedAlarmPlayer?.stop();
    } catch (e) {
      // Do nothing
    }

    // Decrement instance counter
    _instanceCount--;

    // Only dispose when the last instance is disposed
    if (_instanceCount <= 0) {
      try {
        _sharedAlarmPlayer?.dispose();
        _sharedAlarmPlayer = null;
        _instanceCount = 0; // Reset counter to prevent negative counts
      } catch (e) {
        // Do nothing
      }
    }
  }

  // Play alarm sound and vibrate
  Future<void> _playAlarm() async {
    // Initialize audio if not already done
    await _initAudio();

    final feedbackSettings = AppConfig.feedbackSettings;

    // Vibrate with pattern
    if (_hasVibrator && feedbackSettings.hapticEnabled) {
      Vibration.cancel();
      Vibration.vibrate(
        pattern: [0, 2000],
        intensities: [0, 255],
      );
    }

    // Don't attempt to play if audio isn't ready or sound is disabled
    if (_alarmPlayer == null || !feedbackSettings.soundEnabled) {
      return;
    }

    // Play alarm sound
    try {
      // Stop any previous tick audio
      await _alarmPlayer!.pause();
      // Reset position to beginning
      await _alarmPlayer!.seek(Duration.zero);
      // Use resume instead of play to avoid reloading
      await _alarmPlayer!.resume();
    } catch (e) {
      // Do nothing
    }
  }

  // Stop alarm sound and vibration
  void _stopAlarm() {
    try {
      _alarmPlayer?.stop();
      Vibration.cancel();
    } catch (e) {
      // Do nothing
    }
  }

  @override
  void initState() {
    super.initState();
    // Automatically trigger the VotingStarted event when the page loads
    Future.microtask(() {
      if (mounted) {
        final gameState = context.read<GameBloc>().state;
        if (gameState.game.phase != GamePhase.voting) {
          context.read<GameBloc>().add(const VotingStarted());
        }

        // Play alarm when page loads only if shouldPlayAlarm is true
        if (widget.shouldPlayAlarm) {
          _playAlarm();
        }
      }
    });
  }

  @override
  void dispose() {
    _disposeAudio();
    super.dispose();
  }

  // Handle sudden death (1 minute timer for tiebreaker)
  void _startSuddenDeath() {
    // Stop the alarm
    _stopAlarm();

    // First dispatch the event
    context.read<GameBloc>().add(const SuddenDeathStarted());

    // Replace the current route instead of just popping
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const DiscussionPage(),
      ),
    );
  }

  void _navigateToResults() {
    if (_selectedPlayerId != null) {
      // Stop the alarm
      _stopAlarm();

      // Only update the state, don't navigate here - let the BlocConsumer handle navigation
      context.read<GameBloc>().add(PlayerVoted(
            selectedPlayerId: _selectedPlayerId!,
          ));
      // Navigation will be handled by the BlocConsumer listener
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppExitScope(
      child: BlocConsumer<GameBloc, GameState>(
        listenWhen: (previous, current) =>
            previous.game.selectedPlayerId != current.game.selectedPlayerId &&
            current.game.selectedPlayerId != null,
        listener: (context, state) {
          // Get the selected player
          final selectedPlayer = state.game.players.firstWhere(
            (player) => player.id == state.game.selectedPlayerId,
            orElse: () => Player.empty(),
          );

          // Check if we need to show Wolf's Revenge page
          if (selectedPlayer.role == PlayerRole.wolf &&
              state.game.wolfRevengeEnabled) {
            // Navigate to Wolf's Revenge page
            Navigator.of(context).pushReplacement(WolfRevengePage.route());
          } else {
            // Direct to results page
            Navigator.of(context).pushReplacement(ResultsPage.route());
          }
        },
        builder: (context, state) {
          final game = state.game;
          final wolfCount = game.players
              .where((player) => player.role == PlayerRole.wolf)
              .length;

          return Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.voting,
                variant: AppTextVariant.titleLarge,
              ),
              leading: AppExitScope.createBackIconButton(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  AppText(
                    l10n.votingTitle(wolfCount),
                    variant: AppTextVariant.titleLarge,
                    weight: AppTextWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.votingSubtitle(wolfCount),
                    variant: AppTextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Player selection list
                  Expanded(
                    child: _buildPlayerSelectionList(game.players),
                  ),
                  // _buildPlayerSelectionList(game.players),

                  const SizedBox(height: AppSpacing.md),

                  // Confirm button
                  AppButton(
                    variant: AppButtonVariant.filled,
                    onPressed: _navigateToResults,
                    disabled: _selectedPlayerId == null,
                    child: AppText(
                      l10n.confirm,
                      variant: AppTextVariant.titleMedium,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Sudden Death button
                  AppButton(
                    variant: AppButtonVariant.outlined,
                    onPressed: _startSuddenDeath,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          l10n.suddenDeath,
                          variant: AppTextVariant.titleMedium,
                        ),
                        AppText(
                          l10n.suddenDeathSubtitle,
                          variant: AppTextVariant.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerSelectionList(List<Player> players) {
    final l10n = context.l10n;

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: players.length,
      shrinkWrap: true,
      primary: false,
      // separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final player = players[index];
        final isSelected = player.id == _selectedPlayerId;

        return Card(
          child: AppListTile(
            title: AppText(
              player.name,
              variant: AppTextVariant.titleMedium,
              weight: AppTextWeight.medium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: AppText(
              !player.isDefaultName ? l10n.playerDefaultName(index + 1) : "",
              variant: AppTextVariant.bodyMedium,
              colorOption: AppTextColor.onSurfaceVariant,
            ),
            selected: isSelected,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isSelected
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
            ),
            onTap: () {
              setState(() {
                // Toggle selection if already selected
                if (_selectedPlayerId == player.id) {
                  _selectedPlayerId = null;
                } else {
                  _selectedPlayerId = player.id;
                }
              });
            },
          ),
        );
      },
    );
  }
}
