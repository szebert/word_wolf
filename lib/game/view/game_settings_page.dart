import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_button.dart";
import "../../app_ui/widgets/app_checkbox_list_tile.dart";
import "../../app_ui/widgets/app_icon_button.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../models/game.dart";
import "game_categories_page.dart";

class GameSettingsPage extends StatelessWidget {
  const GameSettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GameSettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const GameSettingsView();
  }
}

class GameSettingsView extends StatefulWidget {
  const GameSettingsView({super.key});

  @override
  State<GameSettingsView> createState() => _GameSettingsViewState();
}

class _GameSettingsViewState extends State<GameSettingsView> {
  @override
  void initState() {
    super.initState();
    // Automatically trigger the SetupStarted event when the page loads
    Future.microtask(() {
      if (mounted) {
        context.read<GameBloc>().add(const SetupStarted());
      }
    });
  }

  void _continueToNextStep() {
    Navigator.of(context).push(GameCategoriesPage.route());
  }

  void _onAutoAssignUpdated(bool value) {
    context.read<GameBloc>().add(AutoAssignUpdated(enabled: value));
  }

  Widget _buildAutoAssignToggle() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        return previous.game.autoAssignWolves != current.game.autoAssignWolves;
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final totalPlayers = state.game.players.length;
        final defaultWolfCount = Game.getDefaultWolfCount(totalPlayers);

        return AppCheckboxListTile(
          dense: true,
          title: AppText(l10n.autoAssign),
          subtitle: AppText(
            l10n.autoAssignSubtitle(
              defaultWolfCount,
              totalPlayers,
            ),
            variant: AppTextVariant.bodySmall,
          ),
          value: state.game.autoAssignWolves,
          onChanged: (value) => _onAutoAssignUpdated(value ?? false),
        );
      },
    );
  }

  void _onRandomizeWolfCountUpdated(bool value) {
    context.read<GameBloc>().add(RandomizeWolfCountUpdated(enabled: value));
  }

  Widget _buildRandomizeToggle() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        return previous.game.randomizeWolfCount !=
            current.game.randomizeWolfCount;
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final totalPlayers = state.game.players.length;
        final maxWolves = Game.getMaxWolfCount(totalPlayers);
        final randomizeWolfCount = state.game.randomizeWolfCount;

        return AppCheckboxListTile(
          disabled: maxWolves < 2 && !randomizeWolfCount,
          dense: true,
          title: AppText(l10n.randomize),
          subtitle: AppText(
            l10n.randomizeSubtitle,
            variant: AppTextVariant.bodySmall,
          ),
          value: randomizeWolfCount,
          onChanged: (value) => _onRandomizeWolfCountUpdated(value ?? false),
        );
      },
    );
  }

  Widget _buildCitizensCount() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        return previous.game.customWolfCount != current.game.customWolfCount ||
            previous.game.randomizeWolfCount !=
                current.game.randomizeWolfCount ||
            previous.game.autoAssignWolves != current.game.autoAssignWolves;
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final totalPlayers = state.game.players.length;
        final defaultWolfCount = Game.getDefaultWolfCount(totalPlayers);
        final defaultCitizenCount = totalPlayers - defaultWolfCount;
        final customWolfCount = state.game.customWolfCount ?? defaultWolfCount;
        final customCitizenCount = totalPlayers - customWolfCount;
        final currentCitizenCount = state.game.autoAssignWolves
            ? defaultCitizenCount
            : customCitizenCount;

        return AppText(
          state.game.randomizeWolfCount
              ? l10n.hiddenNumber
              : "$currentCitizenCount",
          variant: AppTextVariant.displaySmall,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Widget _buildWolvesCount() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        return previous.game.customWolfCount != current.game.customWolfCount ||
            previous.game.randomizeWolfCount !=
                current.game.randomizeWolfCount ||
            previous.game.autoAssignWolves != current.game.autoAssignWolves;
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final totalPlayers = state.game.players.length;
        final defaultWolfCount = Game.getDefaultWolfCount(totalPlayers);
        final customWolfCount = state.game.customWolfCount ?? defaultWolfCount;
        final currentWolfCount =
            state.game.autoAssignWolves ? defaultWolfCount : customWolfCount;

        return AppText(
          state.game.randomizeWolfCount
              ? l10n.hiddenNumber
              : "$currentWolfCount",
          variant: AppTextVariant.displaySmall,
          textAlign: TextAlign.center,
        );
      },
    );
  }

  void _decrementWolves() {
    context.read<GameBloc>().add(WolvesCountUpdated(count: -1));
  }

  void _incrementWolves() {
    context.read<GameBloc>().add(WolvesCountUpdated(count: 1));
  }

  Widget _buildWolvesButtons() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) {
        return previous.game.customWolfCount != current.game.customWolfCount ||
            previous.game.randomizeWolfCount !=
                current.game.randomizeWolfCount ||
            previous.game.autoAssignWolves != current.game.autoAssignWolves;
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final autoAssignComposition = state.game.autoAssignWolves;
        final randomizeWolfCount = state.game.randomizeWolfCount;
        final totalPlayers = state.game.players.length;
        final defaultWolfCount = Game.getDefaultWolfCount(totalPlayers);
        final maxWolves = Game.getMaxWolfCount(totalPlayers);
        final customWolfCount = state.game.customWolfCount ?? defaultWolfCount;
        final currentWolfCount =
            autoAssignComposition ? defaultWolfCount : customWolfCount;
        final enableCustomWolves =
            !autoAssignComposition && !randomizeWolfCount;
        final canDecrementWolves = currentWolfCount > 1 && enableCustomWolves;
        final canIncrementWolves =
            currentWolfCount < maxWolves && enableCustomWolves;

        return SizedBox(
          width: 120,
          child: Visibility(
            visible: enableCustomWolves,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIconButton(
                  icon: const Icon(Icons.arrow_circle_left),
                  tooltip: l10n.moreCitizens,
                  iconSize: 32,
                  disabled: !canDecrementWolves,
                  onPressed: _decrementWolves,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppIconButton(
                  icon: const Icon(Icons.arrow_circle_right),
                  tooltip: l10n.moreWolves,
                  iconSize: 32,
                  disabled: !canIncrementWolves,
                  onPressed: _incrementWolves,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _decrementDuration() {
    context.read<GameBloc>().add(GameDiscussionTimeUpdated(timeInSeconds: -60));
  }

  void _incrementDuration() {
    context.read<GameBloc>().add(GameDiscussionTimeUpdated(timeInSeconds: 60));
  }

  Widget _buildDurationWithButtons() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.game.discussionTimeInSeconds !=
          current.game.discussionTimeInSeconds,
      builder: (context, state) {
        final l10n = context.l10n;
        final discussionDuration = state.game.discussionTimeInSeconds;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconButton(
              icon: const Icon(Icons.remove_circle),
              tooltip: l10n.decreaseDuration,
              iconSize: 32,
              disabled: discussionDuration <= 60,
              onPressed: _decrementDuration,
            ),
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  AppText(
                    "${discussionDuration ~/ 60}",
                    variant: AppTextVariant.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  AppText(
                    l10n.minutes,
                    variant: AppTextVariant.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            AppIconButton(
              icon: const Icon(Icons.add_circle),
              tooltip: l10n.increaseDuration,
              iconSize: 32,
              disabled: discussionDuration >= 30 * 60,
              onPressed: _incrementDuration,
            ),
          ],
        );
      },
    );
  }

  void _updateWordPairSimilarity(double value) {
    // Use the dedicated event for updating word pair similarity
    context.read<GameBloc>().add(WordPairSimilarityUpdated(similarity: value));
  }

  Widget _buildWordPairSimilaritySlider() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.game.wordPairSimilarity != current.game.wordPairSimilarity,
      builder: (context, state) {
        final l10n = context.l10n;

        return Slider(
          value: state.game.wordPairSimilarity,
          onChanged: _updateWordPairSimilarity,
          divisions: 10,
          label: Game.getSimilarityDescription(
            l10n,
            state.game.wordPairSimilarity,
          ),
        );
      },
    );
  }

  String _getExampleWordPair(AppLocalizations l10n, double similarityValue) {
    if (similarityValue < 0.1) {
      return l10n.exampleExtremelySimilar;
    } else if (similarityValue < 0.3) {
      return l10n.exampleVerySimilar;
    } else if (similarityValue < 0.5) {
      return l10n.exampleSimilar;
    } else if (similarityValue <= 0.7) {
      return l10n.exampleDifferent;
    } else if (similarityValue <= 0.9) {
      return l10n.exampleVeryDifferent;
    } else {
      return l10n.exampleExtremelyDifferent;
    }
  }

  Widget _buildExampleWordPair() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.game.wordPairSimilarity != current.game.wordPairSimilarity,
      builder: (context, state) {
        final l10n = context.l10n;

        return Center(
          child: AppText(
            _getExampleWordPair(l10n, state.game.wordPairSimilarity),
            variant: AppTextVariant.bodyMedium,
          ),
        );
      },
    );
  }

  void _onWolfRevengeChanged(bool value) {
    context.read<GameBloc>().add(WolfRevengeUpdated(enabled: value));
  }

  Widget _buildWolfRevengeToggle() {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.game.wolfRevengeEnabled != current.game.wolfRevengeEnabled,
      builder: (context, state) {
        final l10n = context.l10n;

        return AppCheckboxListTile(
          dense: true,
          title: AppText(l10n.enableWolfRevenge),
          subtitle: AppText(
            l10n.wolfRevengeSubtitle,
            variant: AppTextVariant.bodySmall,
          ),
          value: state.game.wolfRevengeEnabled,
          onChanged: (value) => _onWolfRevengeChanged(value ?? false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          l10n.gameSettings,
          variant: AppTextVariant.titleLarge,
        ),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.back,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Player Composition Section
                    AppText(
                      l10n.playerComposition,
                      variant: AppTextVariant.titleMedium,
                      weight: AppTextWeight.bold,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Auto-assign toggle
                    _buildAutoAssignToggle(),

                    // Randomize toggle
                    _buildRandomizeToggle(),

                    const SizedBox(height: AppSpacing.xs),

                    // Player composition display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Citizens count
                        Expanded(
                          child: Column(
                            children: [
                              _buildCitizensCount(),
                              AppText(
                                l10n.citizens,
                                variant: AppTextVariant.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Arrows to adjust wolves/citizens ratio
                        _buildWolvesButtons(),

                        // Wolves count
                        Expanded(
                          child: Column(
                            children: [
                              _buildWolvesCount(),
                              AppText(
                                l10n.wolves,
                                variant: AppTextVariant.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),

                    // Discussion Duration
                    AppText(
                      l10n.discussionDuration,
                      variant: AppTextVariant.titleMedium,
                      weight: AppTextWeight.bold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildDurationWithButtons(),

                    const SizedBox(height: AppSpacing.xs),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),

                    // Word Pair Similarity Section
                    AppText(
                      l10n.wordPairSimilarity,
                      variant: AppTextVariant.titleMedium,
                      weight: AppTextWeight.bold,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      l10n.wordPairSimilaritySubtitle,
                      variant: AppTextVariant.bodySmall,
                    ),

                    Row(
                      children: [
                        AppText(
                          l10n.similar,
                          variant: AppTextVariant.bodySmall,
                        ),
                        Expanded(
                          child: _buildWordPairSimilaritySlider(),
                        ),
                        AppText(
                          l10n.different,
                          variant: AppTextVariant.bodySmall,
                        ),
                      ],
                    ),

                    _buildExampleWordPair(),

                    const SizedBox(height: AppSpacing.xs),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),

                    // Wolf's Revenge Section
                    AppText(
                      l10n.wolfRevenge,
                      variant: AppTextVariant.titleMedium,
                      weight: AppTextWeight.bold,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    _buildWolfRevengeToggle(),
                  ],
                ),
              ),
            ),

            // Continue button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
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
            ),
          ],
        ),
      ),
    );
  }
}
