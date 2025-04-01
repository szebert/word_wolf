import 'package:flutter/material.dart';

import '../app_ui/app_spacing.dart';
import '../app_ui/widgets/app_icon_button.dart';
import '../app_ui/widgets/app_text.dart';
import '../l10n/l10n.dart';

class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const HowToPlayPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HowToPlayView();
  }
}

class HowToPlayView extends StatelessWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          l10n.howToPlay,
          variant: AppTextVariant.titleLarge,
          weight: AppTextWeight.medium,
        ),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AppText(
                l10n.howToPlayGameTitle,
                variant: AppTextVariant.displaySmall,
                weight: AppTextWeight.bold,
                colorOption: AppTextColor.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: AppText(
                l10n.howToPlayIntro,
                variant: AppTextVariant.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: AppText(
                  l10n.howToPlayGameFlow,
                  variant: AppTextVariant.titleMedium,
                  weight: AppTextWeight.bold,
                  colorOption: AppTextColor.primary,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Divider(),

            // Word Assignment section
            _buildSectionHeader(context, '1', l10n.howToPlayWordAssignment),
            _buildBulletPoint(context, l10n.howToPlayReceiveWord),
            _buildBulletPoint(context, l10n.howToPlayKeepSecret),
            _buildBulletPoint(context, l10n.howToPlayTwoWords),
            _buildBulletPoint(context, l10n.howToPlayUnknownRole),
            const SizedBox(height: AppSpacing.md),

            // Discussion section
            _buildSectionHeader(context, '2', l10n.howToPlayDiscussion),
            _buildBulletPoint(context, l10n.howToPlayFindWolf),
            _buildBulletPoint(context, l10n.howToPlaySameWord),
            _buildBulletPoint(context, l10n.howToPlaySubtleMisleading),
            const SizedBox(height: AppSpacing.md),

            // Voting section
            _buildSectionHeader(context, '3', l10n.howToPlayVoting),
            _buildBulletPoint(context, l10n.howToPlayPoint),
            _buildBulletPoint(context, l10n.howToPlayElimination),
            _buildBulletPoint(context, l10n.howToPlayTie),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xlg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(context, l10n.howToPlaySuddenDeath),
                  _buildBulletPoint(context, l10n.howToPlayRepeat),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // How to Win section
            AppText(
              l10n.howToPlayHowToWin,
              variant: AppTextVariant.titleMedium,
              weight: AppTextWeight.bold,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildBulletPoint(context, l10n.howToPlayCitizensWin),
            _buildBulletPoint(context, l10n.howToPlayWolvesWin),
            _buildBulletPoint(context, l10n.howToPlayWolfRevenge),
            const Divider(height: AppSpacing.xlg),

            // Tips section
            AppText(
              l10n.howToPlaySpiceUp,
              variant: AppTextVariant.titleMedium,
              weight: AppTextWeight.bold,
              colorOption: AppTextColor.secondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.howToPlayTryIdeas,
              variant: AppTextVariant.bodyLarge,
            ),
            _buildBulletPoint(context, l10n.howToPlayTakeTurns),
            _buildBulletPoint(context, l10n.howToPlayNoLying),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.howToPlayMakeRules,
              variant: AppTextVariant.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: AppText(
                l10n.howToPlayEnjoy,
                variant: AppTextVariant.titleMedium,
                weight: AppTextWeight.medium,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          AppText(
            '$number.',
            variant: AppTextVariant.titleLarge,
            weight: AppTextWeight.bold,
            colorOption: AppTextColor.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.titleLarge,
              weight: AppTextWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
