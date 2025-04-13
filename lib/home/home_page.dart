import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../api/api_config_page.dart";
import "../app/app_bloc.dart";
import "../app_ui/app_spacing.dart";
import "../app_ui/widgets/app_button.dart";
import "../app_ui/widgets/app_icon_button.dart";
import "../app_ui/widgets/app_logo.dart";
import "../app_ui/widgets/app_text.dart";
import "../game/view/player_setup_page.dart";
import "../how_to_play/how_to_play_page.dart";
import "../l10n/l10n.dart";
import "../settings/settings_page.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        actions: [
          AppIconButton(
            icon: const Icon(Icons.api),
            onPressed: () => Navigator.of(context).push(APIConfigPage.route()),
            tooltip: l10n.aiCustomizationTitle,
          ),
          AppIconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(SettingsPage.route()),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(),
                      const SizedBox(height: AppSpacing.xlg),
                      AppText(
                        l10n.appTitle,
                        variant: AppTextVariant.displayLarge,
                        weight: AppTextWeight.bold,
                        textAlign: TextAlign.center,
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
                          Navigator.of(context).push(PlayerSetupPage.route());
                        },
                        child: AppText(
                          l10n.startGame,
                          variant: AppTextVariant.titleLarge,
                          weight: AppTextWeight.medium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xlg),
                      BlocBuilder<AppBloc, AppState>(
                        builder: (context, state) {
                          return AppButton(
                            variant: AppButtonVariant.outlined,
                            shape: AppButtonShape.rounded,
                            size: AppButtonSize.xlarge,
                            minWidth: 200,
                            pulse: !state.hasViewedHowToPlay,
                            onPressed: () {
                              Navigator.of(context).push(HowToPlayPage.route());
                            },
                            child: AppText(
                              l10n.howToPlay,
                              variant: AppTextVariant.titleLarge,
                              weight: AppTextWeight.medium,
                            ),
                          );
                        },
                      ),
                    ],
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
