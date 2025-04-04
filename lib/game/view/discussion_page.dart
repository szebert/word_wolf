import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_ui/app_spacing.dart';
import '../../app_ui/widgets/app_exit_scope.dart';
import '../../app_ui/widgets/app_text.dart';
import '../../l10n/l10n.dart';
import '../bloc/game_bloc.dart';
import '../models/game.dart';
import '../models/player.dart';

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

class _DiscussionViewState extends State<DiscussionView> {
  @override
  void initState() {
    super.initState();
    // Automatically trigger the XYZ event when the page loads
    Future.microtask(() {
      if (mounted) {
        // context.read<GameBloc>().add(const XYZ());
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

          return Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.wordDistribution,
                variant: AppTextVariant.titleLarge,
              ),
              leading: AppExitScope.createBackButton(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game data display
                  Expanded(
                    child: _buildGameDataCard(game),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameDataCard(Game game) {
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
