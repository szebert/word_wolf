import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_ui/app_spacing.dart';
import '../../app_ui/widgets/app_button.dart';
import '../../app_ui/widgets/app_exit_scope.dart';
import '../../app_ui/widgets/app_list_tile.dart';
import '../../app_ui/widgets/app_text.dart';
import '../../l10n/l10n.dart';
import '../bloc/game_bloc.dart';
import '../models/game.dart';
import '../models/player.dart';
import 'discussion_page.dart';
import 'results_page.dart';

class VotingPage extends StatelessWidget {
  const VotingPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const VotingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const VotingView();
  }
}

class VotingView extends StatefulWidget {
  const VotingView({super.key});

  @override
  State<VotingView> createState() => _VotingViewState();
}

class _VotingViewState extends State<VotingView> {
  String? _selectedPlayerId;

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
      }
    });
  }

  // Handle sudden death (1 minute timer for tiebreaker)
  void _startSuddenDeath() {
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
      // Add the selected player ID to the game state
      context
          .read<GameBloc>()
          .add(PlayerVoted(selectedPlayerId: _selectedPlayerId!));
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
          Navigator.of(context).push(ResultsPage.route());
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
              !player.isDefaultName ? l10n.playerDefaultName(index + 1) : '',
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
