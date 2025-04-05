import "package:flutter/material.dart";

import "../app_config.dart";

/// {@template app_checkbox_list_tile}
/// A CheckboxListTile with app-specific feedback settings.
/// {@endtemplate}
class AppCheckboxListTile extends CheckboxListTile {
  /// {@macro app_checkbox_list_tile}
  AppCheckboxListTile({
    required bool value,
    required ValueChanged<bool?>? onChanged,
    super.key,
    super.title,
    super.subtitle,
    super.dense,
    super.contentPadding,
    super.visualDensity,
    super.shape,
    super.tileColor,
    super.selected,
    super.selectedTileColor,
    super.secondary,
    super.controlAffinity,
    super.autofocus = false,
  }) : super(
          value: value,
          onChanged: onChanged == null
              ? null
              : (bool? newValue) {
                  AppConfig.playFeedback();
                  onChanged(newValue);
                },
          enableFeedback: false,
        );
}
