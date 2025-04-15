import "dart:async";

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
import "../services/timer_feedback_manager.dart";
import "voting_page.dart";

class DiscussionPage extends StatelessWidget {
  const DiscussionPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const DiscussionPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const DiscussionView();
  }
}

class DiscussionView extends StatefulWidget {
  const DiscussionView({super.key});

  @override
  State<DiscussionView> createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView>
    with SingleTickerProviderStateMixin {
  bool _isPaused = false;
  int _selectedIcebreakerIndex = -1;

  // Track which icebreakers have had their labels revealed
  Set<int> _revealedLabels = {};

  // Animation controller for statement fade
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Timer feedback manager for audio and haptic feedback
  final _feedbackManager = TimerFeedbackManager();

  @override
  void initState() {
    super.initState();

    // Initialize audio/haptic feedback
    _feedbackManager.initialize();

    // Initialize game timer and advance to discussion phase if needed
    Future.microtask(() {
      if (!mounted) return;

      final gameState = context.read<GameBloc>().state;

      // Initialize _revealedLabels from game state
      setState(() {
        _revealedLabels =
            Set<int>.from(gameState.game.revealedIcebreakerIndices);
      });
    });

    // Add a listener for game phase changes
    Future.microtask(() {
      if (!mounted) return;

      // Listen for game phase changes and navigate when it changes to voting
      context.read<GameBloc>().stream.listen((state) {
        if (state.game.phase == GamePhase.voting && mounted) {
          _feedbackManager.stopFeedback();
          _isPaused = false;
          Navigator.of(context).pushReplacement(VotingPage.route());
        }

        // Monitor timer for ticking functionality
        final timeRemaining = state.game.remainingTimeInSeconds;

        // Handle tick sounds for last 10 seconds
        if (timeRemaining > 0 && timeRemaining <= 10 && !_isPaused) {
          _feedbackManager.playTickTock(timeRemaining);
        } else if (timeRemaining > 10) {
          // Reset when we go back above 10 seconds
          _feedbackManager.resetTickTracking();
        }
      });
    });

    // Initialize animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _feedbackManager.dispose();
    super.dispose();
  }

  void _togglePause() {
    final bloc = context.read<GameBloc>();
    setState(() {
      _isPaused = !_isPaused;
    });

    // Pause audio feedback when timer is paused
    if (_isPaused) {
      _feedbackManager.stopFeedback();
    }

    // Pause or resume the game timer
    bloc.add(GameTimerPaused(paused: _isPaused));
  }

  void _adjustTime(int minutes) {
    final gameState = context.read<GameBloc>().state.game;
    final currentTime = gameState.remainingTimeInSeconds;

    if (currentTime <= 0) return;

    final newValue = currentTime + (minutes * 60);

    if (newValue < 1 || newValue >= 100 * 60) return;

    context.read<GameBloc>().add(GameTimerAdjusted(
          newTimeInSeconds: newValue,
        ));

    // Reset tick tracking if needed
    if (newValue > 10) {
      _feedbackManager.resetTickTracking();
    }
  }

  void _endDiscussion() {
    _feedbackManager.stopFeedback();
    _isPaused = false;
    // Update game phase first
    context.read<GameBloc>().add(const VotingStarted());
    // Advance to voting page with alarm disabled
    Navigator.of(context)
        .pushReplacement(VotingPage.route(shouldPlayAlarm: false));
  }

  void _handleIcebreakerTap(int index) {
    setState(() {
      if (_selectedIcebreakerIndex == index) {
        // Already selected - deselect it
        _fadeController.reverse();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _selectedIcebreakerIndex = -1;
            });
          }
        });
      } else {
        // Newly selected
        if (_revealedLabels.contains(index)) {
          // Label already revealed, show statement
          _selectedIcebreakerIndex = index;
          _fadeController.forward();
        } else {
          // First time clicking - just reveal the label
          _revealedLabels.add(index);
          // Also update the game state
          context.read<GameBloc>().add(IcebreakerLabelRevealed(index: index));
          _selectedIcebreakerIndex = -1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppExitScope(
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final game = state.game;
          final categoryState = context.read<CategoryBloc>().state;

          return Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.discussion,
                variant: AppTextVariant.titleLarge,
              ),
              leading: AppExitScope.createBackIconButton(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCategorySection(game, categoryState.selectedCategory),
                  _buildTimerSection(),
                  _buildIcebreakersSection(game),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(Game game, String category) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category at the top left
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
                    category.isEmpty ? l10n.noCategorySelected : category,
                    variant: AppTextVariant.labelLarge,
                    weight: AppTextWeight.medium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    colorOption: category.isEmpty
                        ? AppTextColor.onSurfaceVariant
                        : AppTextColor.unspecified,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTimerSection() {
    final gameState = context.read<GameBloc>().state.game;
    final minutes = gameState.remainingTimeInSeconds ~/ 60;
    final seconds = gameState.remainingTimeInSeconds % 60;
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.xxlg),

        // Timer with minus/plus buttons on the sides
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Minus button on left
            AppIconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 36),
              tooltip: l10n.decreaseDuration,
              disabled: gameState.remainingTimeInSeconds <= 60 + 1,
              onPressed: () => _adjustTime(-1),
              color: Theme.of(context).colorScheme.primary,
            ),

            // Timer display in center
            AppText(
              l10n.timerValue(
                minutes.toString().padLeft(2, "0"),
                seconds.toString().padLeft(2, "0"),
              ),
              variant: AppTextVariant.displayMedium,
              weight: AppTextWeight.bold,
              colorOption: gameState.remainingTimeInSeconds < 60
                  ? AppTextColor.error
                  : AppTextColor.unspecified,
            ),

            // Plus button on right
            AppIconButton(
              icon: const Icon(Icons.add_circle_outline, size: 36),
              tooltip: l10n.increaseDuration,
              disabled: gameState.remainingTimeInSeconds >= 60 * (100 - 1),
              onPressed: () => _adjustTime(1),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Control Buttons - Side-by-side pause/resume and end
        Row(
          children: [
            // Pause/Resume button
            Expanded(
              child: AppButton(
                onPressed: _togglePause,
                variant: AppButtonVariant.filled,
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause_outlined,
                  size: 20,
                ),
                iconAlignment: IconAlignment.end,
                child: AppText(
                  _isPaused ? l10n.resume : l10n.pause,
                  variant: AppTextVariant.labelLarge,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // End button
            Expanded(
              child: AppButton(
                onPressed: _isPaused ? _endDiscussion : null,
                variant: AppButtonVariant.outlined,
                icon: const Icon(Icons.stop, size: 20),
                iconAlignment: IconAlignment.end,
                child: AppText(
                  l10n.endDiscussion,
                  variant: AppTextVariant.labelLarge,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxlg),
      ],
    );
  }

  Widget _buildIcebreakersSection(Game game) {
    final l10n = context.l10n;

    // No icebreakers available
    if (game.icebreakers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.icebreakers,
          variant: AppTextVariant.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          l10n.icebreakersSubtitle,
          variant: AppTextVariant.bodySmall,
          colorOption: AppTextColor.onSurfaceVariant,
        ),
        const SizedBox(height: AppSpacing.md),

        // Icebreaker buttons row
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: game.icebreakers.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final icebreaker = game.icebreakers[index];
              final isSelected = index == _selectedIcebreakerIndex;
              final isLabelRevealed = _revealedLabels.contains(index);

              return AppButton(
                variant: AppButtonVariant.outlined,
                shape: AppButtonShape.pill,
                onPressed: () => _handleIcebreakerTap(index),
                style: isSelected
                    ? OutlinedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: AppText(
                    isLabelRevealed
                        ? icebreaker.label
                        : l10n.icebreakerUnrevealed,
                  ),
                ),
              );
            },
          ),
        ),

        // Statement with fade transition
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.md),
          height: _selectedIcebreakerIndex >= 0 &&
                  _selectedIcebreakerIndex < game.icebreakers.length &&
                  _revealedLabels.contains(_selectedIcebreakerIndex)
              ? null // Auto height when visible
              : 0, // Zero height when hidden
          child: ClipRect(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedIcebreakerIndex >= 0 &&
                        _selectedIcebreakerIndex < game.icebreakers.length
                    ? AppText(
                        game.icebreakers[_selectedIcebreakerIndex].statement,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
