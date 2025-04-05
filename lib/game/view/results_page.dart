import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_exit_scope.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../category/bloc/category_bloc.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../models/player.dart";

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ResultsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ResultsView();
  }
}

class ResultsView extends StatelessWidget {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppExitScope(
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final game = state.game;
          final categoryState = context.read<CategoryBloc>().state;
          final category = categoryState.selectedCategory;

          // Get the selected player
          final selectedPlayer = game.selectedPlayerId != null
              ? game.players.firstWhere(
                  (player) => player.id == game.selectedPlayerId,
                  orElse: () => Player.empty(),
                )
              : Player.empty();

          // Determine if citizens or wolves won
          final eliminatedPlayerIsWolf = selectedPlayer.role == PlayerRole.wolf;

          // Wolf's Revenge reverses the outcome if successful
          final wolfRevengeSuccessful = eliminatedPlayerIsWolf &&
              game.wolfRevengeAttempted &&
              game.wolfRevengeSuccessful;

          // Citizens win if a wolf is eliminated (unless revenge was successful)
          // Wolves win if a citizen is eliminated OR if wolf revenge was successful
          final citizenWon = eliminatedPlayerIsWolf && !wolfRevengeSuccessful;

          // Get lists of citizens and wolves
          final citizens = game.players
              .where((player) => player.role == PlayerRole.citizen)
              .toList();
          final wolves = game.players
              .where((player) => player.role == PlayerRole.wolf)
              .toList();

          final wolvesCount = wolves.length;

          return Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.results,
                variant: AppTextVariant.titleLarge,
              ),
              leading: AppExitScope.createBackIconButton(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            l10n.category,
                            variant: AppTextVariant.labelLarge,
                            colorOption: AppTextColor.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: AppText(
                              category.isEmpty
                                  ? l10n.noCategorySelected
                                  : category,
                              variant: AppTextVariant.labelLarge,
                              weight: AppTextWeight.medium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Results title
                  AppText(
                    citizenWon ? l10n.citizensWin : l10n.wolvesWin(wolvesCount),
                    variant: AppTextVariant.headlineLarge,
                    weight: AppTextWeight.bold,
                    textAlign: TextAlign.center,
                    colorOption:
                        citizenWon ? AppTextColor.primary : AppTextColor.error,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Words section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Citizen word column
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              l10n.citizens,
                              variant: AppTextVariant.titleLarge,
                              weight: AppTextWeight.medium,
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Card(
                                color: Theme.of(context).colorScheme.secondary,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                  child: AppText(
                                    game.citizenWord,
                                    variant: AppTextVariant.titleLarge,
                                    textAlign: TextAlign.center,
                                    colorOption: AppTextColor.onSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Wolf word column
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              l10n.wolves,
                              variant: AppTextVariant.titleLarge,
                              weight: AppTextWeight.medium,
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Card(
                                color: Theme.of(context).colorScheme.secondary,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md,
                                  ),
                                  child: AppText(
                                    game.wolfWord,
                                    variant: AppTextVariant.titleLarge,
                                    textAlign: TextAlign.center,
                                    colorOption: AppTextColor.onSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Player lists
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Citizens list
                        Expanded(
                          child: _buildPlayerList(
                            citizens,
                            selectedPlayer,
                            game.players,
                            wolfRevengeSuccessful,
                          ),
                        ),

                        // Wolves list
                        Expanded(
                          child: _buildPlayerList(
                            wolves,
                            selectedPlayer,
                            game.players,
                            wolfRevengeSuccessful,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Exit button
                  AppExitScope.createExitButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerList(
    List<Player> players,
    Player selectedPlayer,
    List<Player> allPlayers,
    bool wolfRevengeSuccessful,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            // padding: const EdgeInsets.all(AppSpacing.sm),
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) {
              final player = players[index];
              final isEliminated = player.id == selectedPlayer.id;
              final isCitizen = player.role == PlayerRole.citizen;
              final l10n = context.l10n;

              // Find original index in the full players list
              final originalIndex =
                  allPlayers.indexWhere((p) => p.id == player.id);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isCitizen
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(200)
                            : Theme.of(context)
                                .colorScheme
                                .error
                                .withAlpha(200),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            player.name,
                            variant: AppTextVariant.titleMedium,
                            weight: AppTextWeight.medium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  !player.isDefaultName
                                      ? l10n
                                          .playerDefaultName(originalIndex + 1)
                                      : "",
                                  variant: AppTextVariant.bodyMedium,
                                  colorOption: AppTextColor.onSurfaceVariant,
                                ),
                              ),
                              if (isEliminated)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: wolfRevengeSuccessful
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: AppText(
                                    wolfRevengeSuccessful
                                        ? l10n.revenged
                                        : l10n.eliminated,
                                    variant: AppTextVariant.labelSmall,
                                    colorOption: wolfRevengeSuccessful
                                        ? AppTextColor.onPrimary
                                        : AppTextColor.onError,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
