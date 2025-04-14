import "package:flutter/material.dart";

import "../app_ui/app_spacing.dart";
import "../app_ui/widgets/app_button.dart";
import "../app_ui/widgets/app_icon_button.dart";
import "../app_ui/widgets/app_text.dart";
import "../l10n/l10n.dart";

/// A dedicated page for routes that don't exist (404 equivalent)
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({
    this.routeName,
    super.key,
  });

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const NotFoundPage(),
    );
  }

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: AppText(l10n.notFound),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.back,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                l10n.notFoundTitle,
                variant: AppTextVariant.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              if (routeName != null)
                AppText(
                  l10n.notFoundRoute(routeName!),
                  variant: AppTextVariant.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: AppSpacing.xlg),
              AppButton(
                variant: AppButtonVariant.elevated,
                size: AppButtonSize.xlarge,
                minWidth: 200,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                iconAlignment: IconAlignment.start,
                child: AppText(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
