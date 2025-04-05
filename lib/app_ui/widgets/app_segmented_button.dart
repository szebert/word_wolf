import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../app_config.dart";
import "../app_spacing.dart";

/// {@template app_segmented_button}
/// A customized segmented button widget that follows the app's design system.
/// {@endtemplate}
class AppSegmentedButton<T> extends StatelessWidget {
  /// {@macro app_segmented_button}
  const AppSegmentedButton({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.showSelectedIcon = false,
    super.key,
  });

  /// The list of segments to display.
  final List<ButtonSegment<T>> segments;

  /// The currently selected segment value(s).
  final Set<T> selected;

  /// Called when the user selects a segment.
  final void Function(Set<T>) onSelectionChanged;

  /// Whether to show the selected icon on the active segment.
  final bool showSelectedIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<FeedbackSettings>(
      valueListenable: AppConfig.feedbackSettingsNotifier,
      builder: (context, feedbackSettings, _) {
        return SegmentedButton<T>(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return theme.colorScheme.surface.withAlpha(200);
              }
              if (states.contains(WidgetState.selected)) {
                return theme.colorScheme.primary;
              }
              return theme.colorScheme.surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return theme.colorScheme.onSurface.withAlpha(64);
              }
              if (states.contains(WidgetState.selected)) {
                return theme.colorScheme.onPrimary;
              }
              return theme.colorScheme.onSurface;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(
                  color: theme.colorScheme.onSurface.withAlpha(32),
                );
              }
              return BorderSide(color: theme.colorScheme.primary);
            }),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            enableFeedback: false,
          ),
          segments: segments,
          selected: selected,
          onSelectionChanged: (newSelection) {
            if (feedbackSettings.hapticEnabled) {
              HapticFeedback.lightImpact();
            }
            if (feedbackSettings.soundEnabled) {
              SystemSound.play(SystemSoundType.click);
            }
            onSelectionChanged(newSelection);
          },
          showSelectedIcon: showSelectedIcon,
        );
      },
    );
  }
}
