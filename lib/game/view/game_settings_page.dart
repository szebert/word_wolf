import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_ui/app_spacing.dart';
import '../../app_ui/widgets/app_button.dart';
import '../../app_ui/widgets/app_icon_button.dart';
import '../../app_ui/widgets/app_text.dart';
import '../../l10n/l10n.dart';
import '../bloc/game_bloc.dart';
import 'game_categories_page.dart';

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
  bool _autoAssignComposition = true;
  bool _randomizeWolfCount = false;
  int _discussionDuration = 3;
  int _numberOfWolves = 1;

  @override
  void initState() {
    super.initState();
    final gameState = context.read<GameBloc>().state;
    final totalPlayers = gameState.game.players.length;

    // Initialize settings from game state
    _autoAssignComposition = gameState.game.autoAssignWolves;
    _randomizeWolfCount = gameState.game.randomizeWolfCount;
    _discussionDuration = (gameState.game.discussionTimeInSeconds / 60).round();

    // Set number of wolves based on auto-assign state
    if (_autoAssignComposition) {
      _numberOfWolves = getNumberOfBalancedWolves(totalPlayers);
    } else {
      _numberOfWolves = gameState.game.customWolfCount ??
          getNumberOfBalancedWolves(totalPlayers);
    }
  }

  @override
  void didUpdateWidget(GameSettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final gameState = context.read<GameBloc>().state;
    final totalPlayers = gameState.game.players.length;

    // If auto-assign is enabled, update wolf count when player count changes
    if (_autoAssignComposition) {
      final newWolfCount = getNumberOfBalancedWolves(totalPlayers);
      if (_numberOfWolves != newWolfCount) {
        setState(() {
          _numberOfWolves = newWolfCount;
        });
        // Update the game state with new wolf count
        context.read<GameBloc>().add(
              WolvesCountUpdated(
                customWolfCount: newWolfCount,
                randomizeWolfCount: _randomizeWolfCount,
                autoAssignWolves: _autoAssignComposition,
              ),
            );
      }
    }
  }

  int getNumberOfBalancedWolves(int totalPlayers) {
    // Use ceil to round up - ensures enough wolves for larger groups
    return (totalPlayers / 5).ceil();
  }

  void _onAutoAssignChanged(bool value) {
    setState(() {
      _autoAssignComposition = value;
      _randomizeWolfCount = !value && _randomizeWolfCount;

      if (value) {
        final totalPlayers = context.read<GameBloc>().state.game.players.length;
        _numberOfWolves = getNumberOfBalancedWolves(totalPlayers);
      }
    });
    context.read<GameBloc>().add(
          WolvesCountUpdated(
            customWolfCount: _numberOfWolves,
            randomizeWolfCount: _randomizeWolfCount,
            autoAssignWolves: _autoAssignComposition,
          ),
        );
  }

  void _onRandomizeWolfCountChanged(bool value) {
    setState(() {
      _randomizeWolfCount = value;
      _autoAssignComposition = !value && _autoAssignComposition;
    });
    context.read<GameBloc>().add(
          WolvesCountUpdated(
            customWolfCount: _randomizeWolfCount ? null : _numberOfWolves,
            randomizeWolfCount: _randomizeWolfCount,
            autoAssignWolves: _autoAssignComposition,
          ),
        );
  }

  void _decrementWolves() {
    if (_numberOfWolves > 1) {
      setState(() {
        _numberOfWolves--;
      });
      context.read<GameBloc>().add(
            WolvesCountUpdated(
              customWolfCount: _numberOfWolves,
              randomizeWolfCount: _randomizeWolfCount,
              autoAssignWolves: _autoAssignComposition,
            ),
          );
    }
  }

  void _incrementWolves() {
    final totalPlayers = context.read<GameBloc>().state.game.players.length;
    // Wolves must be less than citizens, so max is (totalPlayers - 1) / 2
    final maxWolves = ((totalPlayers - 1) / 2).floor();

    if (_numberOfWolves < maxWolves) {
      setState(() {
        _numberOfWolves++;
      });
      context.read<GameBloc>().add(
            WolvesCountUpdated(
              customWolfCount: _numberOfWolves,
              randomizeWolfCount: _randomizeWolfCount,
              autoAssignWolves: _autoAssignComposition,
            ),
          );
    }
  }

  void _decrementDuration() {
    if (_discussionDuration > 1) {
      setState(() {
        _discussionDuration--;
      });
      context.read<GameBloc>().add(
            GameDiscussionTimeUpdated(
              timeInSeconds: _discussionDuration * 60,
            ),
          );
    }
  }

  void _incrementDuration() {
    if (_discussionDuration < 30) {
      setState(() {
        _discussionDuration++;
      });
      context.read<GameBloc>().add(
            GameDiscussionTimeUpdated(
              timeInSeconds: _discussionDuration * 60,
            ),
          );
    }
  }

  void _updateWordPairSimilarity(double value) {
    // Use the dedicated event for updating word pair similarity
    context.read<GameBloc>().add(WordPairSimilarityUpdated(similarity: value));
  }

  String _getSimilarityDescription(
      AppLocalizations l10n, double similarityValue) {
    if (similarityValue < 0.1) {
      return l10n.extremelySimilar;
    } else if (similarityValue < 0.3) {
      return l10n.verySimilar;
    } else if (similarityValue < 0.5) {
      return l10n.similar;
    } else if (similarityValue <= 0.7) {
      return l10n.different;
    } else if (similarityValue <= 0.9) {
      return l10n.veryDifferent;
    } else {
      return l10n.extremelyDifferent;
    }
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

  void _continueToNextStep() {
    Navigator.of(context).push(GameCategoriesPage.route());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gameState = context.watch<GameBloc>().state;
    final totalPlayers = gameState.game.players.length;
    final maxWolves = ((totalPlayers - 1) / 2).floor();
    final canDecrementWolves =
        _numberOfWolves > 1 && !_autoAssignComposition && !_randomizeWolfCount;
    final canIncrementWolves = _numberOfWolves < maxWolves &&
        !_autoAssignComposition &&
        !_randomizeWolfCount;

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
                    CheckboxListTile(
                      dense: true,
                      title: AppText(l10n.autoAssign),
                      subtitle: AppText(
                        l10n.autoAssignSubtitle(
                          getNumberOfBalancedWolves(totalPlayers),
                          totalPlayers,
                        ),
                        variant: AppTextVariant.bodySmall,
                      ),
                      value: _autoAssignComposition,
                      onChanged: (value) =>
                          _onAutoAssignChanged(value ?? false),
                    ),

                    // Randomize toggle
                    CheckboxListTile(
                      dense: true,
                      title: AppText(l10n.randomize),
                      subtitle: AppText(
                        l10n.randomizeSubtitle,
                        variant: AppTextVariant.bodySmall,
                      ),
                      value: _randomizeWolfCount,
                      onChanged: (value) =>
                          _onRandomizeWolfCountChanged(value ?? false),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // Player composition display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Citizens count
                        Expanded(
                          child: Column(
                            children: [
                              AppText(
                                _randomizeWolfCount
                                    ? '?'
                                    : '${totalPlayers - _numberOfWolves}',
                                variant: AppTextVariant.displaySmall,
                                textAlign: TextAlign.center,
                              ),
                              AppText(
                                l10n.citizens,
                                variant: AppTextVariant.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Arrows to adjust wolves/citizens ratio
                        SizedBox(
                          width: 120,
                          child: Visibility(
                            visible:
                                !_autoAssignComposition && !_randomizeWolfCount,
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
                                  onPressed: canDecrementWolves
                                      ? _decrementWolves
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                AppIconButton(
                                  icon: const Icon(Icons.arrow_circle_right),
                                  tooltip: l10n.moreWolves,
                                  iconSize: 32,
                                  onPressed: canIncrementWolves
                                      ? _incrementWolves
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Wolves count
                        Expanded(
                          child: Column(
                            children: [
                              AppText(
                                _randomizeWolfCount ? '?' : '$_numberOfWolves',
                                variant: AppTextVariant.displaySmall,
                                textAlign: TextAlign.center,
                              ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIconButton(
                          icon: const Icon(Icons.remove_circle),
                          tooltip: l10n.decreaseDuration,
                          iconSize: 32,
                          onPressed: _discussionDuration > 1
                              ? _decrementDuration
                              : null,
                        ),
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              AppText(
                                '$_discussionDuration',
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
                          onPressed: _discussionDuration < 30
                              ? _incrementDuration
                              : null,
                        ),
                      ],
                    ),
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
                          child: BlocBuilder<GameBloc, GameState>(
                            buildWhen: (previous, current) =>
                                previous.game.wordPairSimilarity !=
                                current.game.wordPairSimilarity,
                            builder: (context, state) {
                              return Slider(
                                value: state.game.wordPairSimilarity,
                                onChanged: _updateWordPairSimilarity,
                                divisions: 10,
                                label: _getSimilarityDescription(
                                  l10n,
                                  state.game.wordPairSimilarity,
                                ),
                              );
                            },
                          ),
                        ),
                        AppText(
                          l10n.different,
                          variant: AppTextVariant.bodySmall,
                        ),
                      ],
                    ),

                    BlocBuilder<GameBloc, GameState>(
                      buildWhen: (previous, current) =>
                          previous.game.wordPairSimilarity !=
                          current.game.wordPairSimilarity,
                      builder: (context, state) {
                        return Center(
                          child: AppText(
                            _getExampleWordPair(
                                l10n, state.game.wordPairSimilarity),
                            variant: AppTextVariant.bodyMedium,
                          ),
                        );
                      },
                    ),
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
