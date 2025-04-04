import 'package:flutter/material.dart';

import '../../home/home_page.dart';
import '../../l10n/l10n.dart';
import 'app_button.dart';
import 'app_icon_button.dart';
import 'app_text.dart';

/// {@template app_exit_scope}
/// A widget that handles back navigation with a confirmation dialog.
/// Prevents accidental exits from important flows like game pages.
/// {@endtemplate}
class AppExitScope extends StatelessWidget {
  /// {@macro app_exit_scope}
  const AppExitScope({
    required this.child,
    this.onExit,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional callback when exit is confirmed.
  /// If not provided, defaults to navigating to HomePage.
  final VoidCallback? onExit;

  /// Shows a dialog asking the user to confirm exiting.
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

  /// Navigates to the HomePage and clears the navigation history.
  void _exitToMainMenu(BuildContext context) {
    // Navigate to the HomePage and clear the navigation history
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  /// Creates a back button that shows the exit confirmation dialog.
  static Widget createBackButton(BuildContext context) {
    final l10n = context.l10n;

    return AppIconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: l10n.exitGame,
      onPressed: () async {
        final shouldExit = await showDialog<bool>(
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
        if (shouldExit == true && context.mounted) {
          // Navigate to the HomePage and clear the navigation history
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          if (onExit != null) {
            onExit!();
          } else {
            _exitToMainMenu(context);
          }
        }
      },
      child: child,
    );
  }
}
