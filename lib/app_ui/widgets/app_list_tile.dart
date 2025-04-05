import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../app_config.dart";

/// {@template app_list_tile}
/// A ListTile with app-specific feedback settings.
/// {@endtemplate}
class AppListTile extends ListTile {
  /// {@macro app_list_tile}
  AppListTile({
    required VoidCallback? onTap,
    super.key,
    super.dense,
    super.contentPadding,
    super.visualDensity,
    super.shape,
    super.tileColor,
    super.title,
    super.subtitle,
    super.selected,
    super.selectedTileColor,
    super.trailing,
    super.style,
  }) : super(
          onTap: onTap == null
              ? null
              : () {
                  final feedbackSettings =
                      AppConfig.feedbackSettingsNotifier.value;
                  if (feedbackSettings.hapticEnabled) {
                    HapticFeedback.lightImpact();
                  }
                  if (feedbackSettings.soundEnabled) {
                    SystemSound.play(SystemSoundType.click);
                  }
                  onTap();
                },
          enableFeedback: false,
        );
}
