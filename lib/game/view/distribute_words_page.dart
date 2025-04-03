import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_ui/app_spacing.dart';
import '../../app_ui/widgets/app_button.dart';
import '../../app_ui/widgets/app_icon_button.dart';
import '../../app_ui/widgets/app_text.dart';
import '../../home/home_page.dart';
import '../../l10n/l10n.dart';
import '../bloc/game_bloc.dart';
import '../models/game.dart';
import '../models/player.dart';

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
  @override
  void initState() {
    super.initState();
    // Automatically trigger the GameStarted event when the page loads
    Future.microtask(() {
      if (mounted) {
        context.read<GameBloc>().add(const GameStarted());
      }
    });
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final l10n = context.l10n;

        return AlertDialog(
          title: AppText(l10n.exitGame),
          content: AppText(
            l10n.exitGameContent,
          ),
          actions: <Widget>[
            AppButton(
              variant: AppButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop(true),
              child: AppText(l10n.ok),
            ),
            AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () => Navigator.of(context).pop(false),
              child: AppText(l10n.cancel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _exitToMainMenu(BuildContext context) {
    // Navigate to the HomePage and clear the navigation history
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Use PopScope to intercept system back button/gesture
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          _exitToMainMenu(context);
        }
      },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final game = state.game;

          return Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.wordDistribution,
                variant: AppTextVariant.titleLarge,
              ),
              leading: AppIconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.exitGame,
                onPressed: () async {
                  final shouldExit = await _showExitConfirmationDialog(context);
                  if (shouldExit && context.mounted) {
                    _exitToMainMenu(context);
                  }
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game data display
                  Expanded(
                    child: _buildGameDataCard(game, state.status),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameDataCard(Game game, GameStatus status) {
    final l10n = context.l10n;

    // Show loading indicator if the game is in loading state
    if (status == GameStatus.loading) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              AppText(l10n.wordDistributionLoading),
            ],
          ),
        ),
      );
    }

    // Show the game data when loaded
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataSection(
                'General Settings',
                [
                  'Selected category: ${game.category.isNotEmpty ? game.category : "None"}',
                  'Word pair similarity: ${game.wordPairSimilarity} (${_formatSimilarity(game.wordPairSimilarity)})',
                  'Discussion time: ${game.discussionTimeInSeconds ~/ 60} minutes',
                ],
              ),
              const Divider(),
              _buildDataSection(
                'Player Composition',
                [
                  'Total players: ${game.players.length}',
                  'Number of wolves: ${game.wolfCount}',
                  'Auto-assign wolves: ${game.autoAssignWolves ? "Yes" : "No"}',
                  'Randomize wolf count: ${game.randomizeWolfCount ? "Yes" : "No"}',
                ],
              ),
              const Divider(),
              _buildDataSection(
                'Words',
                [
                  'Citizen word: ${game.citizenWord}',
                  'Wolf word: ${game.wolfWord}',
                ],
              ),
              const Divider(),
              _buildDataSection(
                'Players',
                game.players
                    .map((player) =>
                        '${player.name} - ${_formatRole(player.role)}')
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: AppTextVariant.titleSmall,
          weight: AppTextWeight.bold,
        ),
        const SizedBox(height: AppSpacing.xs),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                bottom: AppSpacing.xs,
              ),
              child: AppText(item),
            )),
      ],
    );
  }

  String _formatSimilarity(double similarity) {
    if (similarity < 0.1) {
      return 'Extremely Similar';
    } else if (similarity < 0.3) {
      return 'Very Similar';
    } else if (similarity < 0.5) {
      return 'Similar';
    } else if (similarity <= 0.7) {
      return 'Different';
    } else if (similarity <= 0.9) {
      return 'Very Different';
    } else {
      return 'Extremely Different';
    }
  }

  String _formatRole(PlayerRole role) {
    switch (role) {
      case PlayerRole.wolf:
        return 'Wolf';
      case PlayerRole.citizen:
        return 'Citizen';
      case PlayerRole.undecided:
        return 'Undecided';
    }
  }
}
