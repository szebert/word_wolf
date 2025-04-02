import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_ui/app_spacing.dart';
import '../../app_ui/widgets/app_icon_button.dart';
import '../../app_ui/widgets/app_text.dart';
import '../../l10n/l10n.dart';
import '../bloc/game_bloc.dart';

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

class DistributeWordsView extends StatelessWidget {
  const DistributeWordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final game = state.game;

        return Scaffold(
          appBar: AppBar(
            title: AppText(
              'Word Distribution',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Game data display
                Expanded(
                  child: Card(
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
                                  .map((player) => player.name)
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
}
