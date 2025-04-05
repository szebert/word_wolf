import "package:flutter/material.dart";

import "../app_config.dart";

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
    super.iconSize,
    super.color,
    super.tooltip,
    super.constraints,
    super.visualDensity,
    super.padding,
  }) : super(
          onPressed: onPressed == null
              ? null
              : () {
                  AppConfig.playFeedback();
                  onPressed();
                },
          style: const ButtonStyle(
            enableFeedback: false,
          ).merge(style),
        );
}
