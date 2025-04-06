import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_button.dart";
import "../../app_ui/widgets/app_exit_scope.dart";
import "../../app_ui/widgets/app_icon_button.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../category/bloc/category_bloc.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../models/game.dart";
import "../models/player.dart";
import "discussion_page.dart";

class DistributeWordsPage extends StatelessWidget {
  const DistributeWordsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const DistributeWordsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const DistributeWordsView();
  }
}

class DistributeWordsView extends StatefulWidget {
  const DistributeWordsView({super.key});

  @override
  State<DistributeWordsView> createState() => _DistributeWordsViewState();
}

class _DistributeWordsViewState extends State<DistributeWordsView> {
  // Track current player index and phase
  int currentPlayerIndex = 0;
  int currentPhase = 1;
  bool allPlayersFinished = false;

  @override
  void initState() {
    super.initState();
    // Automatically trigger the GameStarted event when the page loads
    Future.microtask(() {
      if (mounted) {
        final gameState = context.read<GameBloc>().state;
        final categoryState = context.read<CategoryBloc>().state;
        // Only start a new discussion if we're not in it already
        if (gameState.game.phase != GamePhase.wordAssignment) {
          context
              .read<GameBloc>()
              .add(GameStarted(category: categoryState.selectedCategory));
        }
      }
    });
  }

  void _toggleWordVisibility() {
    setState(() {
      if (currentPhase < 3) {
        currentPhase += 1;
      }
    });
  }

  void _previousPhase() {
    setState(() {
      if (currentPhase > 1) {
        currentPhase -= 1;
      }
    });
  }

  void _nextPlayer() {
    setState(() {
      currentPhase = 1;
      currentPlayerIndex += 1;

      // Check if all players have completed
      final players = context.read<GameBloc>().state.game.players;
      if (currentPlayerIndex >= players.length) {
        allPlayersFinished = true;
      }
    });
  }

  void _continueToNextStep() {
    // Navigate to the discussion page
    Navigator.of(context).push(DiscussionPage.route());
  }

  Widget _goBackButton() {
    final l10n = context.l10n;

    return AppIconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: l10n.back,
      onPressed: () async {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final game = state.game;
        final categoryState = context.read<CategoryBloc>().state;

        return AppExitScope(
          disabled: state.status == GameStatus.error,
          child: Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.wordDistribution,
                variant: AppTextVariant.titleLarge,
              ),
              leading: state.status == GameStatus.error
                  ? _goBackButton()
                  : AppExitScope.createBackIconButton(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildContent(
                game,
                state.status,
                categoryState.selectedCategory,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(Game game, GameStatus status, String category) {
    final l10n = context.l10n;

    // Show loading indicator if the game is in loading state
    if (status == GameStatus.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            AppText(l10n.wordDistributionLoading),
          ],
        ),
      );
    }

    if (status == GameStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.wordGenerationErrorTitle,
                  variant: AppTextVariant.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: 300,
                  child: AppText(
                    l10n.wordGenerationErrorContent,
                    variant: AppTextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (category.isNotEmpty)
                  SizedBox(
                    width: 300,
                    child: AppText(
                      l10n.wordGenerationErrorCategoryNote,
                      variant: AppTextVariant.bodySmall,
                      colorOption: AppTextColor.secondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xlg),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        variant: AppButtonVariant.filled,
                        onPressed: () {
                          // Use offline words instead
                          context.read<GameBloc>().add(
                                GameStartedOffline(
                                  category: category,
                                ),
                              );
                        },
                        child: AppText(
                          l10n.wordGenerationErrorContinue,
                          variant: AppTextVariant.titleMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        variant: AppButtonVariant.outlined,
                        onPressed: () async {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: AppText(
                          l10n.exitToMenu,
                          variant: AppTextVariant.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // If all players have seen their words, show the start discussion button
    if (allPlayersFinished) {
      return _buildAllPlayersFinishedView();
    }

    // Get the current player
    final currentPlayer = game.players[currentPlayerIndex];

    return _buildPlayerWordView(currentPlayer, game, category);
  }

  Widget _buildAllPlayersFinishedView() {
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 300,
          child: AppText(
            l10n.allPlayersFinished,
            variant: AppTextVariant.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xlg),
        AppButton(
          minWidth: double.infinity,
          variant: AppButtonVariant.filled,
          onPressed: _continueToNextStep,
          child: AppText(
            l10n.startDiscussion,
            variant: AppTextVariant.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerWordView(Player player, Game game, String category) {
    final playerWord =
        (player.role == PlayerRole.wolf) ? game.wolfWord : game.citizenWord;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top section - name aligned to bottom
        Expanded(
          flex: 3,
          child: _buildPhaseHeader(player, category),
        ),

        // Middle section - content centered
        Expanded(
          flex: 4,
          child: Center(
            child: _buildPhaseContent(currentPhase, player, playerWord),
          ),
        ),

        // Bottom section - buttons aligned to bottom
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPhaseButtons(currentPhase),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseHeader(Player player, String category) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category at the top left
        if (category.isNotEmpty)
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
                      category,
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

        // Push the player name to the bottom
        const Spacer(),

        // Player name centered at the bottom
        Center(
          child: Column(
            children: [
              AppText(
                player.name,
                variant: AppTextVariant.displaySmall,
                weight: AppTextWeight.bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Only show default name as subtitle if player has a custom name
              if (!player.isDefaultName)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: AppText(
                    l10n.playerDefaultName(currentPlayerIndex + 1),
                    variant: AppTextVariant.titleLarge,
                    colorOption: AppTextColor.onSurfaceVariant,
                  ),
                ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseContent(int phase, Player player, String word) {
    // Use non-centered Column with fixed spacers for consistent positioning
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Fixed top space
        const SizedBox(height: AppSpacing.xxlg),
        // Icon always in the same position
        _getPhaseIcon(phase),
        // Fixed spacing between icon and content
        const SizedBox(height: AppSpacing.lg),
        // Content
        _getPhaseContent(phase, word),
        // Remaining space to push everything up
        const Spacer(),
      ],
    );
  }

  Widget _getPhaseIcon(int phase) {
    IconData icon;
    switch (phase) {
      case 1:
        icon = Icons.visibility_off;
      case 2:
        icon = Icons.help_outline;
      case 3:
        icon = Icons.visibility;
      default:
        icon = Icons.help_outline;
    }

    return Icon(
      icon,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _getPhaseContent(int phase, String word) {
    final l10n = context.l10n;

    switch (phase) {
      case 1:
        return SizedBox(
          width: 300,
          child: AppText(
            l10n.displayWordPhase1,
            variant: AppTextVariant.titleMedium,
            textAlign: TextAlign.center,
          ),
        );
      case 2:
        return SizedBox(
          width: 300,
          child: AppText(
            l10n.displayWordPhase2,
            variant: AppTextVariant.titleMedium,
            textAlign: TextAlign.center,
          ),
        );
      case 3:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              l10n.displayWordPhase3,
              variant: AppTextVariant.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                word,
                variant: AppTextVariant.titleLarge,
                weight: AppTextWeight.bold,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhaseButtons(int phase) {
    final l10n = context.l10n;

    switch (phase) {
      case 1:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppButton(
            minWidth: double.infinity,
            variant: AppButtonVariant.filled,
            onPressed: _toggleWordVisibility,
            child: AppText(
              l10n.show,
              variant: AppTextVariant.titleMedium,
            ),
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                minWidth: double.infinity,
                variant: AppButtonVariant.filled,
                onPressed: _toggleWordVisibility,
                child: AppText(
                  l10n.show,
                  variant: AppTextVariant.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                minWidth: double.infinity,
                variant: AppButtonVariant.outlined,
                onPressed: _previousPhase,
                child: AppText(
                  l10n.cancel,
                  variant: AppTextVariant.titleMedium,
                ),
              ),
            ],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppButton(
            minWidth: double.infinity,
            variant: AppButtonVariant.filled,
            onPressed: _nextPlayer,
            child: AppText(
              l10n.displayWordConfirmation,
              variant: AppTextVariant.titleMedium,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
