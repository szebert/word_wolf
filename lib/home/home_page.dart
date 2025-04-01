import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_ui/app_spacing.dart';
import '../app_ui/widgets/app_button.dart';
import '../app_ui/widgets/app_icon_button.dart';
import '../app_ui/widgets/app_logo.dart';
import '../app_ui/widgets/app_text.dart';
import '../game/bloc/game_bloc.dart';
import '../game/view/player_setup_page.dart';
import '../how_to_play/how_to_play_page.dart';
import '../l10n/l10n.dart';
import '../settings/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        actions: [
          AppIconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(SettingsPage.route()),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              const AppLogo(),
              const SizedBox(height: AppSpacing.xlg),
              AppText(
                l10n.appTitle,
                variant: AppTextVariant.displayLarge,
                weight: AppTextWeight.bold,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: AppText(
                  l10n.appTagline,
                  variant: AppTextVariant.bodyLarge,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xlg),
              AppButton(
                variant: AppButtonVariant.elevated,
                shape: AppButtonShape.rounded,
                size: AppButtonSize.xlarge,
                minWidth: 200,
                onPressed: () {
                  // Initialize the game state before navigating
                  context.read<GameBloc>().add(const GameInitialized());
                  Navigator.of(context).push(PlayerSetupPage.route());
                },
                child: AppText(
                  l10n.startGame,
                  variant: AppTextVariant.titleLarge,
                  weight: AppTextWeight.medium,
                ),
              ),
              const SizedBox(height: AppSpacing.xlg),
              AppButton(
                variant: AppButtonVariant.outlined,
                shape: AppButtonShape.rounded,
                size: AppButtonSize.xlarge,
                minWidth: 200,
                pulse: true,
                onPressed: () {
                  Navigator.of(context).push(HowToPlayPage.route());
                },
                child: AppText(
                  l10n.howToPlay,
                  variant: AppTextVariant.titleLarge,
                  weight: AppTextWeight.medium,
                ),
              ),
              const Expanded(flex: 5, child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
