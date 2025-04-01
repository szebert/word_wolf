import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_config.dart';

/// {@template app_icon_button}
/// An IconButton with app-specific feedback settings.
/// {@endtemplate}
class AppIconButton extends IconButton {
  /// {@macro app_icon_button}
  AppIconButton({
    required super.icon,
    required VoidCallback? onPressed,
    ButtonStyle? style,
    super.key,
    super.tooltip,
    super.constraints,
    super.padding,
  }) : super(
          onPressed: onPressed == null
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
                  onPressed();
                },
          style: const ButtonStyle(
            enableFeedback: false,
          ).merge(style),
        );
}
